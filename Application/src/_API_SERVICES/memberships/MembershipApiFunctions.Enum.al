#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059827 "NPR MembershipApiFunctions"
{
    Extensible = false;
    Access = Internal;
    value(0; NOOP)
    {
        Caption = 'No operation';
    }

    value(100; GET_MEMBERSHIP_USING_NUMBER)
    {
        Caption = 'Get membership using query parameters';
    }
    value(150; GET_MEMBERSHIP_RENEWAL_INFO)
    {
        Caption = 'Get membership renewal info';
    }
    value(200; GET_ALL_PAYMENT_METHODS)
    {
        Caption = 'Get payment methods for a membership';
    }
    value(201; CREATE_PAYMENT_METHOD)
    {
        Caption = 'Create a new payment method for a membership';
    }
    value(202; GET_PAYMENT_METHOD)
    {
        Caption = 'Get an individual payment method';
    }
    value(203; UPDATE_PAYMENT_METHOD)
    {
        Caption = 'Update a payment method';
    }
    value(204; DELETE_PAYMENT_METHOD)
    {
        Caption = 'Delete a payment method';
    }
}
#endif