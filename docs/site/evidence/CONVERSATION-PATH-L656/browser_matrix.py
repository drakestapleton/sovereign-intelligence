# Execute via browser_exec: helpers are injected by the browser harness.
import base64
import json
from pathlib import Path
import shutil

# Bind the real injected helpers explicitly for static analysis as well as execution.
cdp = globals()["cdp"]
js = globals()["js"]
goto_url = globals()["goto_url"]
wait_for_load = globals()["wait_for_load"]
capture_screenshot = globals()["capture_screenshot"]

OUT = Path('/Users/drakestapleton/.hermes/cache/scratch/loop13-personal71/evidence/CONVERSATION-PATH-L656/browser/final')
OUT.mkdir(parents=True, exist_ok=False)
BASE = 'http://127.0.0.1:18731/'
cdp('Network.enable')
cdp('Network.setBlockedURLs', urls=['https://formsubmit.co/*'])

def enter(selector):
    root = cdp('DOM.getDocument')['root']['nodeId']
    node = cdp('DOM.querySelector', nodeId=root, selector=selector)['nodeId']
    if not node:
        raise RuntimeError('missing keyboard target: ' + selector)
    cdp('DOM.focus', nodeId=node)
    cdp('Input.dispatchKeyEvent', type='keyDown', key='Enter', code='Enter', windowsVirtualKeyCode=13, text='\r', unmodifiedText='\r')
    cdp('Input.dispatchKeyEvent', type='keyUp', key='Enter', code='Enter', windowsVirtualKeyCode=13)

def page_probe(expected):
    # Inspector-injected on-new-document code may run with page JS disabled.
    # Exercise an actual page script element instead; verify both modes.
    js('delete window.__l656PageScriptProbe;var s=document.createElement("script");s.textContent="window.__l656PageScriptProbe=123";document.head.appendChild(s);s.remove();')
    actual = js('window.__l656PageScriptProbe===123')
    if actual != expected:
        raise RuntimeError('page script execution mode not proven: ' + str(actual))
    return actual

rows = []
for label, width, height, mobile, enabled in [
    ('desktop',1440,900,False,True), ('phone',390,844,True,True),
    ('desktop',1440,900,False,False), ('phone',390,844,True,False),
]:
    name = label + ('-js' if enabled else '-nojs')
    cdp('Emulation.setScriptExecutionDisabled', value=not enabled)
    cdp('Emulation.setDeviceMetricsOverride', width=width, height=height, deviceScaleFactor=1, mobile=mobile)
    if not mobile:
        zoom = cdp('Page.getLayoutMetrics')['visualViewport'].get('zoom',1)
        cdp('Emulation.setDeviceMetricsOverride', width=round(width*zoom), height=round(height*zoom), deviceScaleFactor=1, mobile=False)
    goto_url(BASE); wait_for_load()
    actual_script = page_probe(enabled)
    home = js('({url:location.href,width:innerWidth,height:innerHeight,scrollWidth:document.documentElement.scrollWidth,qa:window.__qa??null,ctas:Array.from(document.querySelectorAll(".uni-cta a")).map(a=>({name:a.textContent,href:a.getAttribute("href"),rect:a.getBoundingClientRect().toJSON()})),outsideResources:performance.getEntriesByType("resource").filter(r=>new URL(r.name).origin!==location.origin).map(r=>r.name)})')
    if (home['width'],home['height']) != (width,height) or home['scrollWidth']>width or home['outsideResources']:
        raise RuntimeError('homepage viewport/resource failure: '+str(home))
    shutil.copyfile(capture_screenshot(), OUT/(name+'-home.png'))
    enter('.uni-cta a[href="/interest"]'); wait_for_load()
    page_probe(enabled)
    interest = js('({url:location.href,width:innerWidth,height:innerHeight,scrollWidth:document.documentElement.scrollWidth,qa:window.__qa??null,h1:document.querySelector("h1").textContent,h2Font:getComputedStyle(document.querySelector(".prose h2")).fontSize,forms:document.forms.length,action:document.forms[0].action,method:document.forms[0].method,valid:document.forms[0].checkValidity(),novalidate:document.forms[0].noValidate,descriptionIds:document.getElementById("message").getAttribute("aria-describedby"),labels:Array.from(document.querySelectorAll("form input:not([type=hidden]),form textarea")).map(e=>({name:e.name,label:e.labels?.[0]?.textContent,required:e.required})),mailto:document.querySelector("a[href^=mailto]").getAttribute("href"),outsideResources:performance.getEntriesByType("resource").filter(r=>new URL(r.name).origin!==location.origin).map(r=>r.name)})')
    if '/interest' not in interest['url'] or (interest['width'],interest['height'])!=(width,height) or interest['scrollWidth']>width or interest['forms']!=1 or interest['valid'] or interest['novalidate'] or interest['outsideResources']:
        raise RuntimeError('interest-page failure: '+str(interest))
    for view in [home,interest]:
        if view['qa'] and (view['qa']['errors'] or view['qa']['messages']):
            raise RuntimeError('console failure: '+str(view['qa']))
    clip = cdp('Page.getLayoutMetrics')['contentSize']
    (OUT/(name+'-interest-full.png')).write_bytes(base64.b64decode(cdp('Page.captureScreenshot', format='png', captureBeyondViewport=True, clip={**clip,'scale':1})['data']))
    enter('button[type=submit]')
    validation = js('({url:location.href,focused:document.activeElement.id,missing:document.getElementById("name").validity.valueMissing,message:document.getElementById("name").validationMessage})')
    if validation['focused']!='name' or not validation['missing'] or not validation['message'] or '/interest' not in validation['url']:
        raise RuntimeError('native required-field validation failed: '+str(validation))
    tabs = []
    for _ in range(3):
        for typ in ['keyDown','keyUp']:
            cdp('Input.dispatchKeyEvent', type=typ, key='Tab', code='Tab', windowsVirtualKeyCode=9)
        tabs.append(js('({id:document.activeElement.id,tag:document.activeElement.tagName,type:document.activeElement.type})'))
    if [x['id'] for x in tabs[:2]]!=['email','message'] or tabs[2]['tag']!='BUTTON':
        raise RuntimeError('form keyboard order failed: '+str(tabs))
    legacy = []
    for target in ['#w-home','#w-aien']:
        goto_url(BASE); wait_for_load()
        enter('.uni-cta a[href="'+target+'"]')
        state = js('({hash:location.hash,visible:getComputedStyle(document.querySelector(location.hash)).display!=="none"&&getComputedStyle(document.querySelector(location.hash)).visibility!=="hidden"})')
        if state['hash']!=target or not state['visible']:
            raise RuntimeError('retained keyboard action failed: '+str(state))
        legacy.append(state)
    rows.append({'viewport':label,'javascript':enabled,'page_script_probe_executed':actual_script,'home':home,'interest':interest,'keyboard_enter_navigated':True,'native_empty_submit_refused':validation,'third_party_submission_blocked_during_test':True,'form_tab_order':tabs,'retained_actions_keyboard':legacy})
    (OUT/'results.json').write_text(json.dumps(rows,indent=2)+'\n')
    print(name,'PASS: two pages, contextual Enter, native validation, form tab order, both retained actions')
if len({(r['viewport'],r['javascript']) for r in rows})!=4:
    raise RuntimeError('incomplete matrix')
(OUT/'complete.json').write_text(json.dumps({'states':len(rows),'page_views':len(rows)*2,'complete':True,'no_real_submission':True},indent=2)+'\n')
print(str(OUT/'phone-nojs-home.png'))
