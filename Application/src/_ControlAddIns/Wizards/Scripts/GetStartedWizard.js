function controlAddInReady() {
    console.log('controlAddInReady');
    try {
        
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('Ready',null);
    }
    catch (err) { 
        console.log('controlAddInReady Error: ' + err.message);
    }
}
function createlayout(TitleTxt,SubTitleTxt,ExplanationTxt,IntroTxt,IntroDescTxt,GetStartedTxt,GetStartedDescTxt,FindHelpTxt,FindHelpDescTxt)
{
    var mainCanvas = document.getElementById('controlAddIn');
    mainCanvas.className = "mainCanvas";

    var sectionBorder = document.createElement('div');
    sectionBorder.className = "sectionborder";
    mainCanvas.appendChild(sectionBorder);

    var welcomeDiv = document.createElement('div');
    welcomeDiv.className = "welcomediv";
    sectionBorder.appendChild(welcomeDiv);

    var titleDiv = document.createElement('div');
    titleDiv.className = "title titlefont"
    var title = document.createTextNode(TitleTxt);
    titleDiv.appendChild(title);
    welcomeDiv.appendChild(titleDiv);

    var lineBreak = document.createElement('br');
    welcomeDiv.appendChild(lineBreak);


    var subtitleDiv = document.createElement('div');
    subtitleDiv.className = "subtitle brandPrimary titlefont";
    var subtitleTxt = document.createTextNode(SubTitleTxt);
    subtitleDiv.appendChild(subtitleTxt);
    welcomeDiv.appendChild(subtitleDiv);

    var explanationDiv = document.createElement('div');
    explanationDiv.className = "explanation brandSecondary";
    var explanationTxt = document.createTextNode(ExplanationTxt);
    explanationDiv.appendChild(explanationTxt);
    welcomeDiv.appendChild(explanationDiv);

    var welcomeimageDiv = document.createElement('div');
    welcomeimageDiv.className = "welcomeimagediv";
    var welcomeImage = document.createElement('div');
    var image = new Image();
    image.src = Microsoft.Dynamics.NAV.GetImageResource("src/_ControlAddins/Wizards/Images/NP-small-logo.png");
    image.className = "welcomeimage";
    welcomeImage.appendChild(image);
    welcomeimageDiv.appendChild(welcomeImage);
    sectionBorder.appendChild(welcomeimageDiv);

    var links = document.createElement('div');
    links.className = "links";
    mainCanvas.appendChild(links);

    var video1div = document.createElement('div');
    video1div.className = "tile tilemarginright field";
    links.appendChild(video1div);

    var video1title = document.createElement('div');
    video1title.className = "tileDescription";
    var video1titleTxt = document.createTextNode(IntroTxt);
    video1title.appendChild(video1titleTxt);
    video1div.appendChild(video1title);

    var video1desc = document.createElement('div');
    video1desc.className = "segoeRegularfont brandSecondary";
    var video1descTxt = document.createTextNode(IntroDescTxt);
    video1desc.appendChild(video1descTxt);
    video1div.appendChild(video1desc);

    var anchor1 = document.createElement('a');
    var videoImage = new Image();
    videoImage.id = 'videoImage';
    videoImage.src = Microsoft.Dynamics.NAV.GetImageResource("src/_ControlAddins/Wizards/Images/VideoButton.png"); 
    anchor1.appendChild(videoImage);
    video1div.appendChild(anchor1);
    anchor1.onclick = function (){
        var number = 1;
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ThumbnailClicked',[number]);
    }

    var video2div = document.createElement('div');
    video2div.className = "tile tilemarginright field";
    links.appendChild(video2div);

    var video2title = document.createElement('div');
    video2title.className = "tileDescription";
    var video2titleTxt = document.createTextNode(GetStartedTxt);
    video2title.appendChild(video2titleTxt);
    video2div.appendChild(video2title);

    var video2desc = document.createElement('div');
    video2desc.className = "segoeRegularfont brandSecondary";
    var video2descTxt = document.createTextNode(GetStartedDescTxt);
    video2desc.appendChild(video2descTxt);
    video2div.appendChild(video2desc);

    var anchor2 = document.createElement('a');
    var outLookVideo = new Image();
    outLookVideo.id = 'outlookVideo';
    outLookVideo.src = Microsoft.Dynamics.NAV.GetImageResource("src/_ControlAddins/Wizards/Images/OutlookVideo.png");
    anchor2.appendChild(outLookVideo);
    video2div.appendChild(anchor2);
    anchor2.onclick = function (){
        var number = 2;
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ThumbnailClicked',[number]);
    }

    var video3div = document.createElement('div');
    video3div.className = "tile tilemarginright field";
    links.appendChild(video3div);

    var video3title = document.createElement('div');
    video3title.className = "tileDescription";
    var video3titleTxt = document.createTextNode(FindHelpTxt);
    video3title.appendChild(video3titleTxt);
    video3div.appendChild(video3title);

    var video3desc = document.createElement('div');
    video3desc.className = "segoeRegularfont brandSecondary";
    var video3descTxt = document.createTextNode(FindHelpDescTxt);
    video3desc.appendChild(video3descTxt);
    video3div.appendChild(video3desc);

    var anchor3 = document.createElement('a');
    var assistanceVideo = new Image();
    assistanceVideo.id = 'assistanceVideo';
    assistanceVideo.src = Microsoft.Dynamics.NAV.GetImageResource("src/_ControlAddins/Wizards/Images/GetAssistanceVideo.png");
    anchor3.appendChild(assistanceVideo);
    video3div.appendChild(anchor3);
    anchor3.onclick = function (){
        var number = 3;
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ThumbnailClicked',[number]);
    }
}






