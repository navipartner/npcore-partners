controladdin "NPR StripeCreditCardControl"
{
    HorizontalShrink = true;
    HorizontalStretch = true;
    VerticalShrink = false;
    VerticalStretch = true;
    MaximumHeight = 120;
    MaximumWidth = 540;
    MinimumHeight = 120;
    MinimumWidth = 150;
    RequestedHeight = 120;
    RequestedWidth = 300;

    Scripts = 'https://js.stripe.com/v3/',
              './src/Stripe/ControlAddIns/CreditCardControl/Script.js';
    StartupScript = './src/Stripe/ControlAddIns/CreditCardControl/StartupScript.js';
    StyleSheets = './src/Stripe/ControlAddIns/CreditCardControl/Style.css';

    Images = './src/Stripe/ControlAddIns/CreditCardControl/Stripe-wordmark-blurple-small.png';

    event ControlAddInReady();
    procedure InitializeCheckOutForm(publishableKey: Text);
    event InputChanged(complete: Boolean);
    procedure CreateStripeToken();
    event StripeTokenCreated(newTokenId: Text);
}