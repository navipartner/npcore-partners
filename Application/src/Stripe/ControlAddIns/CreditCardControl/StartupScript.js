var mainCanvas = document.getElementById('controlAddIn');
mainCanvas.className = "mainCanvas";

var formRow = document.createElement('div');
formRow.className = "form-row";
mainCanvas.appendChild(formRow);

var cardElement = document.createElement('div');
cardElement.id = "card-element";
formRow.appendChild(cardElement);

var cardErrors = document.createElement('div');
cardErrors.id = "card-errors";
cardErrors.setAttribute("role", "alert");
formRow.appendChild(cardErrors);

var stripelogoDiv = document.createElement('div');
stripelogoDiv.className = "stripe-logo-div";
var stripelogo = document.createElement('div');
var linkTag = document.createElement('a');
linkTag.href = 'https://www.stripe.com/';
linkTag.target = "blank";
var image = new Image();
image.className = "stripe-logo";
image.src = Microsoft.Dynamics.NAV.GetImageResource("src/Stripe/ControlAddIns/CreditCardControl/Stripe-wordmark-blurple-small.png");
image.title = 'Learn more about Stripe.'
linkTag.appendChild(image);
stripelogo.appendChild(linkTag);
stripelogoDiv.appendChild(stripelogo);
mainCanvas.appendChild(stripelogoDiv);

Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlAddInReady', null);
