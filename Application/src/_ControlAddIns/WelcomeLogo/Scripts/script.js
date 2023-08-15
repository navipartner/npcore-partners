function InitComponent(){
debugger;
    var container = window.parent.document.querySelector('.title--1GtoSGcg3pRYxeVfoZom9s');
    container.insertAdjacentHTML('beforebegin', '<img style ="display: block; margin-left: 0; margin-right: auto; margin-bottom: 2rem; width: 35%"; src="' +
                                Microsoft.Dynamics.NAV.GetImageResource('src/_ControlAddins/WelcomeLogo/Images/NPLogo_NEW.png') + '">');
     Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('InsertLogoEvent');
}

if (document.readyState === 'complete'){
    InitComponent();
}else{
    window.addEventListener('load', InitComponent);
}