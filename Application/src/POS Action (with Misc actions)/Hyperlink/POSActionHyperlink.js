let main = async ({workflow, parameters}) => {
    debugger;
    if (parameters["back-end"]){
        await workflow.respond();
    } else {
        if (!parameters.iFrame) {
            window.open(parameters.url, "_blank");
        } else {
            var ifrm = document.createElement("iframe");
            ifrm.src = parameters.url;
            ifrm.id = "iFrameWindow";
            ifrm.onload = function() { 
                ifrm.contentWindow.focus(); 
            };
            ifrm.style.position = "absolute";
            ifrm.style.top="7%";
            ifrm.style.left="7%";
            ifrm.style.height="85%";
            ifrm.style.width="85%";
            ifrm.style.overflow="hidden";
            ifrm.style.zIndex= "101";
            document.body.appendChild(ifrm);

            var button = document.createElement("button");
            button.id = "closeIframe";
            button.style.position = "absolute";
            button.style.top="4%";
            button.style.left="89%";
            button.style.height="3%";
            button.style.width="3%";
            button.style.zIndex= "101";
            button.style.backgroundColor = "red";
            button.style.fontWeight = "900";
            button.innerHTML = 'X';
            document.body.appendChild(button);

            button.addEventListener("click", function() { closeIframe(); });

            var textBoxElement = document.getElementsByClassName("np-textbox")[0];
            if (textBoxElement) textBoxElement.addEventListener('input', closeIframe);

            function closeIframe() {
                var element = document.getElementById("iFrameWindow");
                var element2 = document.getElementById("closeIframe");

                if (element) element.parentNode.removeChild(element);
                if (element2) element2.parentNode.removeChild(element2);
            };

            $(document).on("click", function(e) {
                var iframe = $("iframe");
                if (!iframe.is(e.target) && iframe.has(e.target).length === 0) {
                    closeIframe();
                }
            });
        }
    }
}