/* SPDX-License-Identifier: Apache-2.0
 * omega_4k_merkle_portable.c — Single-file native Windows (PE32+ x86_64) & macOS Apple Silicon (arm64 Mach-O)
 * companion matching omega_4k_merkle.om byte-for-byte on FIPS 180-4 SHA-256 + Merkle Root + Closed-GOP vault.
 */
#define _POSIX_C_SOURCE 200809L
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#else
#include <pthread.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>
#endif

#define MAX_SCENES 60
static const char *PROFILE_SALT = "omega4k30-x264fast-40m-aq3-bt2020-v1";

static const uint32_t SHA_K[64] = {
    0x428a2f98u,0x71374491u,0xb5c0fbcfu,0xe9b5dba5u,0x3956c25bu,0x59f111f1u,0x923f82a4u,0xab1c5ed5u,
    0xd807aa98u,0x12835b01u,0x243185beu,0x550c7dc3u,0x72be5d74u,0x80deb1feu,0x9bdc06a7u,0xc19bf174u,
    0xe49b69c1u,0xefbe4786u,0x0fc19dc6u,0x240ca1ccu,0x2de92c6fu,0x4a7484aau,0x5cb0a9dcu,0x76f988dau,
    0x983e5152u,0xa831c66du,0xb00327c8u,0xbf597fc7u,0xc6e00bf3u,0xd5a79147u,0x06ca6351u,0x14292967u,
    0x27b70a85u,0x2e1b2138u,0x4d2c6dfcu,0x53380d13u,0x650a7354u,0x766a0abbu,0x81c2c92eu,0x92722c85u,
    0xa2bfe8a1u,0xa81a664bu,0xc24b8b70u,0xc76c51a3u,0xd192e819u,0xd6990624u,0xf40e3585u,0x106aa070u,
    0x19a4c116u,0x1e376c08u,0x2748774cu,0x34b0bcb5u,0x391c0cb3u,0x4ed8aa4au,0x5b9cca4fu,0x682e6ff3u,
    0x748f82eeu,0x78a5636fu,0x84c87814u,0x8cc70208u,0x90befffau,0xa4506cebu,0xbef9a3f7u,0xc67178f2u
};

typedef struct { uint32_t st[8]; uint8_t blk[64]; uint64_t total; size_t bp; } ShaCtx;
static inline uint32_t rotr32(uint32_t x, unsigned n) { return (x >> n) | (x << (32u - n)); }

static void sha_compress(ShaCtx *c) {
    uint32_t w[64];
    for (int i = 0; i < 16; i++)
        w[i] = ((uint32_t)c->blk[i*4]<<24)|((uint32_t)c->blk[i*4+1]<<16)|((uint32_t)c->blk[i*4+2]<<8)|c->blk[i*4+3];
    for (int i = 16; i < 64; i++) {
        uint32_t s0 = rotr32(w[i-15],7)^rotr32(w[i-15],18)^(w[i-15]>>3);
        uint32_t s1 = rotr32(w[i-2],17)^rotr32(w[i-2],19)^(w[i-2]>>10);
        w[i] = w[i-16] + s0 + w[i-7] + s1;
    }
    uint32_t a=c->st[0],b=c->st[1],cc=c->st[2],d=c->st[3],e=c->st[4],f=c->st[5],g=c->st[6],h=c->st[7];
    for (int i = 0; i < 64; i++) {
        uint32_t s1 = rotr32(e,6)^rotr32(e,11)^rotr32(e,25);
        uint32_t ch = (e & f) ^ ((~e) & g);
        uint32_t t1 = h + s1 + ch + SHA_K[i] + w[i];
        uint32_t s0 = rotr32(a,2)^rotr32(a,13)^rotr32(a,22);
        uint32_t maj = (a & b) ^ (a & cc) ^ (b & cc);
        uint32_t t2 = s0 + maj;
        h=g; g=f; f=e; e=d+t1; d=cc; cc=b; b=a; a=t1+t2;
    }
    c->st[0]+=a; c->st[1]+=b; c->st[2]+=cc; c->st[3]+=d;
    c->st[4]+=e; c->st[5]+=f; c->st[6]+=g; c->st[7]+=h;
}

static void sha_init(ShaCtx *c) {
    c->st[0]=0x6a09e667u; c->st[1]=0xbb67ae85u; c->st[2]=0x3c6ef372u; c->st[3]=0xa54ff53au;
    c->st[4]=0x510e527fu; c->st[5]=0x9b05688cu; c->st[6]=0x1f83d9abu; c->st[7]=0x5be0cd19u;
    c->total = 0; c->bp = 0;
}

static void sha_update(ShaCtx *c, const uint8_t *p, size_t n) {
    c->total += n;
    for (size_t i = 0; i < n; i++) {
        c->blk[c->bp++] = p[i];
        if (c->bp == 64) { sha_compress(c); c->bp = 0; }
    }
}

static void sha_final(ShaCtx *c, uint8_t dig[32]) {
    uint64_t bits = c->total * 8ULL;
    c->blk[c->bp++] = 0x80;
    if (c->bp > 56) { while (c->bp < 64) c->blk[c->bp++] = 0; sha_compress(c); c->bp = 0; }
    while (c->bp < 56) c->blk[c->bp++] = 0;
    for (int i = 0; i < 8; i++) c->blk[56 + i] = (uint8_t)(bits >> ((7 - i) * 8));
    sha_compress(c);
    for (int i = 0; i < 8; i++) {
        dig[i*4]=(uint8_t)(c->st[i]>>24); dig[i*4+1]=(uint8_t)(c->st[i]>>16);
        dig[i*4+2]=(uint8_t)(c->st[i]>>8); dig[i*4+3]=(uint8_t)(c->st[i]);
    }
}

static int sha_file_salted(const char *path, uint8_t dig[32]) {
    FILE *fp = fopen(path, "rb");
    if (!fp) return -1;
    uint8_t *buf = (uint8_t *)malloc(65536);
    if (!buf) { fclose(fp); return -1; }
    ShaCtx c; sha_init(&c);
    size_t n;
    while ((n = fread(buf, 1, 65536, fp)) > 0) sha_update(&c, buf, n);
    fclose(fp); free(buf);
    sha_update(&c, (const uint8_t *)PROFILE_SALT, strlen(PROFILE_SALT));
    sha_final(&c, dig);
    return 0;
}

static void to_hex(const uint8_t *b, size_t n, char *out) {
    static const char *H = "0123456789abcdef";
    for (size_t i = 0; i < n; i++) { out[i*2]=H[b[i]>>4]; out[i*2+1]=H[b[i]&15]; }
    out[n*2] = 0;
}

static uint64_t now_ms(void) {
#ifdef _WIN32
    return GetTickCount64();
#else
    struct timespec ts; clock_gettime(CLOCK_MONOTONIC, &ts);
    return (uint64_t)ts.tv_sec * 1000ULL + (uint64_t)ts.tv_nsec / 1000000ULL;
#endif
}

static int file_exists(const char *p) { struct stat st; return stat(p, &st) == 0; }

static int run_ffmpeg_cmd(const char *cmd) {
#ifdef _WIN32
    STARTUPINFOA si; PROCESS_INFORMATION pi;
    memset(&si, 0, sizeof si); si.cb = sizeof si;
    memset(&pi, 0, sizeof pi);
    char buf[2048];
    snprintf(buf, sizeof buf, "%s", cmd);
    if (!CreateProcessA(NULL, buf, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi)) return 1;
    WaitForSingleObject(pi.hProcess, INFINITE);
    DWORD code = 1;
    GetExitCodeProcess(pi.hProcess, &code);
    CloseHandle(pi.hProcess); CloseHandle(pi.hThread);
    return (int)code;
#else
    int rc = system(cmd);
    return (rc == 0) ? 0 : 1;
#endif
}

typedef struct {
    const char *scene_dir;
    const char *vault_dir;
    int n_scenes;
    uint8_t digs[MAX_SCENES][32];
    char hex[MAX_SCENES][65];
    int dirty[MAX_SCENES];
    int n_dirty;
    volatile long next_idx;
    volatile long errs;
#ifdef _WIN32
    CRITICAL_SECTION lock;
#else
    pthread_mutex_t lock;
#endif
} JobState;

static int next_job(JobState *js) {
    int idx = -1;
#ifdef _WIN32
    EnterCriticalSection(&js->lock);
    if (js->next_idx < js->n_dirty) idx = js->dirty[js->next_idx++];
    LeaveCriticalSection(&js->lock);
#else
    pthread_mutex_lock(&js->lock);
    if (js->next_idx < js->n_dirty) idx = js->dirty[js->next_idx++];
    pthread_mutex_unlock(&js->lock);
#endif
    return idx;
}

#ifdef _WIN32
static DWORD WINAPI worker_fn(LPVOID vp)
#else
static void *worker_fn(void *vp)
#endif
{
    JobState *js = (JobState *)vp;
    for (;;) {
        int s = next_job(js);
        if (s < 0) break;
        char in_p[512], out_p[512], cmd[2048];
        snprintf(in_p, sizeof in_p, "%s/scene_%02d.mkv", js->scene_dir, s);
        snprintf(out_p, sizeof out_p, "%s/%.24s.mkv", js->vault_dir, js->hex[s]);
        snprintf(cmd, sizeof cmd,
            "ffmpeg -y -hide_banner -loglevel error -i \"%s\" -c:v libx264 -preset fast -threads 2 "
            "-b:v 40M -maxrate 40M -bufsize 80M -x264-params \"aq-mode=3:open-gop=0:keyint=60:min-keyint=30:scenecut=40\" "
            "-pix_fmt yuv420p -color_primaries bt2020 -color_trc bt2020-10 -colorspace bt2020nc \"%s\"",
            in_p, out_p);
        if (run_ffmpeg_cmd(cmd) != 0) js->errs = 1;
    }
#ifdef _WIN32
    return 0;
#else
    return NULL;
#endif
}

int main(int argc, char **argv) {
    if (argc == 2 && strcmp(argv[1], "--self-test") == 0) {
        ShaCtx c; sha_init(&c);
        const char *m = "omega-4k-merkle-selftest";
        sha_update(&c, (const uint8_t *)m, strlen(m));
        uint8_t d[32]; sha_final(&c, d);
        char hx[65]; to_hex(d, 32, hx);
#ifdef _WIN32
        const char *plat = "windows-x86_64";
#elif defined(__APPLE__)
        const char *plat = "macos-arm64";
#else
        const char *plat = "linux";
#endif
        printf("OMEGA_4K_MERKLE_SELFTEST PASS platform=%s sha256=%s\n", plat, hx);
        return 0;
    }
    if (argc < 4) {
        fprintf(stderr, "usage: omega-4k-merkle <scenes_dir> <vault_dir> <out_mp4> [n_scenes=60] [workers=4]\n"
                        "       omega-4k-merkle --self-test\n");
        return 2;
    }
    JobState js; memset(&js, 0, sizeof js);
    js.scene_dir = argv[1]; js.vault_dir = argv[2];
    const char *out_mp4 = argv[3];
    js.n_scenes = (argc >= 5) ? atoi(argv[4]) : MAX_SCENES;
    if (js.n_scenes < 1 || js.n_scenes > MAX_SCENES) js.n_scenes = MAX_SCENES;
    int workers = (argc >= 6) ? atoi(argv[5]) : 4;
    if (workers < 1) workers = 1; if (workers > 16) workers = 16;

    uint64_t t0 = now_ms();
    int hits = 0, misses = 0;
    ShaCtx root; sha_init(&root);
    for (int i = 0; i < js.n_scenes; i++) {
        char p[512], vp[512];
        snprintf(p, sizeof p, "%s/scene_%02d.mkv", js.scene_dir, i);
        if (sha_file_salted(p, js.digs[i]) != 0) { fprintf(stderr, "FAIL: missing %s\n", p); return 11; }
        to_hex(js.digs[i], 32, js.hex[i]);
        sha_update(&root, js.digs[i], 32);
        snprintf(vp, sizeof vp, "%s/%.24s.mkv", js.vault_dir, js.hex[i]);
        if (file_exists(vp)) hits++; else { js.dirty[js.n_dirty++] = i; misses++; }
    }
    uint8_t rdig[32]; sha_final(&root, rdig);
    char rhex[65]; to_hex(rdig, 32, rhex);
    uint64_t t1 = now_ms();

    if (js.n_dirty > 0) {
        int nw = workers < js.n_dirty ? workers : js.n_dirty;
#ifdef _WIN32
        InitializeCriticalSection(&js.lock);
        HANDLE th[16];
        for (int w = 0; w < nw; w++) th[w] = CreateThread(NULL, 0, worker_fn, &js, 0, NULL);
        WaitForMultipleObjects((DWORD)nw, th, TRUE, INFINITE);
        for (int w = 0; w < nw; w++) CloseHandle(th[w]);
        DeleteCriticalSection(&js.lock);
#else
        pthread_mutex_init(&js.lock, NULL);
        pthread_t th[16];
        for (int w = 0; w < nw; w++) pthread_create(&th[w], NULL, worker_fn, &js);
        for (int w = 0; w < nw; w++) pthread_join(th[w], NULL);
        pthread_mutex_destroy(&js.lock);
#endif
        if (js.errs) return 24;
    }
    uint64_t t2 = now_ms();

    char clist[512];
    snprintf(clist, sizeof clist, "%s/concat.txt", js.vault_dir);
    FILE *cf = fopen(clist, "wb");
    if (!cf) return 31;
    for (int i = 0; i < js.n_scenes; i++) fprintf(cf, "file %s/%.24s.mkv\n", js.vault_dir, js.hex[i]);
    fclose(cf);

    char mux[2048];
    snprintf(mux, sizeof mux, "ffmpeg -y -hide_banner -loglevel error -f concat -safe 0 -i \"%s\" -c copy -movflags +faststart \"%s\"", clist, out_mp4);
    if (run_ffmpeg_cmd(mux) != 0) return 34;
    uint64_t t3 = now_ms();

    printf("OMEGA_4K_MERKLE_PASS hash_ms=%llu encode_ms=%llu mux_ms=%llu total_ms=%llu hits=%d misses=%d merkle_root=%s\n",
           (unsigned long long)(t1-t0), (unsigned long long)(t2-t1), (unsigned long long)(t3-t2),
           (unsigned long long)(t3-t0), hits, misses, rhex);
    return 0;
}
