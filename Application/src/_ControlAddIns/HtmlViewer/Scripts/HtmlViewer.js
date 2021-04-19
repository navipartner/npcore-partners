function XSLT(xslstring, xmlstring)
{
    xmlstring = xmlstring.replace("xmlns=\"urn:microsoft-dynamics-nav/xmlports/sales_order\"", "");
    var xslfile = new File([xslstring], "xsltest.xml", {type: "text/xsl"});
    var xslUri = URL.createObjectURL(xslfile);
    var declaration = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><?xml-stylesheet type=\"text/xsl\" href=\"" + xslUri +"\"?>";
    var reg = /<\?xml[\sa-zA-Z=\"0-9\.\-]+\?>/;
    var xml = declaration + xmlstring.split(reg)[1];
    var xmlfile = new File([xml], "xmltest.xml", {type: "text/xml"});
    var xmluri = URL.createObjectURL(xmlfile);
    var iframe = document.createElement("iframe");
    iframe.setAttribute("src", xmluri);
    iframe.setAttribute("style", "height: 100%; width: 100%; border: none;");
    iframe.setAttribute("scrolling", "yes");
    document.getElementById("controlAddIn").innerHTML = "";
    document.getElementById("controlAddIn").appendChild(iframe);
    window.frameElement.setAttribute("scrolling", "yes");
}


