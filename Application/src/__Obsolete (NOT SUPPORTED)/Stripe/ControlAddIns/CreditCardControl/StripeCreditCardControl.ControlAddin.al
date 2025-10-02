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
              'src\__Obsolete (NOT SUPPORTED)\Stripe\ControlAddIns\CreditCardControl\Script.js';
    StartupScript = 'src\__Obsolete (NOT SUPPORTED)\Stripe\ControlAddIns\CreditCardControl\StartupScript.js';
    StyleSheets = 'src\__Obsolete (NOT SUPPORTED)\Stripe\ControlAddIns\CreditCardControl\Style.css';

    Images = 'src\__Obsolete (NOT SUPPORTED)\Stripe\ControlAddIns\CreditCardControl\Stripe-wordmark-blurple-small.png';

    event ControlAddInReady();
    procedure InitializeCheckOutForm(publishableKey: Text);
    event InputChanged(complete: Boolean);
    procedure CreateStripeToken();
    event StripeTokenCreated(newTokenId: Text);
}