var CreateStripeToken;

function InitializeCheckOutForm(publishableKey) {
    var stripe = Stripe(publishableKey);
    var elements = stripe.elements();

    var style = {
        base: {
            color: 'white',
            fontFamily: '"Segoe UI", "Segoe WP", Segoe, device-segoe, Tahoma, Helvetica, Arial, sans-serif',
            fontSmoothing: 'antialiased',
            fontSize: '16px',
            '::placeholder': {
                color: '#505C6D'
            }
        },
        invalid: {
            color: '#E11414',
            iconColor: '#E11414',
        }
    };

    var options = {
        style: style,
        hidePostalCode: true
    };

    var card = elements.create('card', options);
    card.mount('#card-element');

    // Handle real-time validation errors from the card Element.
    card.addEventListener('change', function (event) {
        var displayError = document.getElementById('card-errors');
        if (event.error) {
            displayError.textContent = event.error.message;
        } else {
            displayError.textContent = '';
        }
        var arguments = [event.complete];
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('InputChanged', arguments);
    });

    CreateStripeToken = function () {
        stripe.createToken(card).then(function (result) {
            if (result.error) {
                // Inform the user if there was an error
                var errorElement = document.getElementById('card-errors');
                errorElement.textContent = result.error.message;
            } else {
                // Send the token to your server
                stripeTokenHandler(result.token);
            }
        });
    }
}

function stripeTokenHandler(token) {
    var arguments = [token.id];
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('StripeTokenCreated', arguments);
}

