#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059827 "NPR MembershipApiFunctions"
{
    Extensible = false;
    Access = Internal;
    value(0; NOOP)
    {
        Caption = 'No operation';
    }
    value(50; GET_CATALOG)
    {
        Caption = 'Get membership catalog';
    }

    value(100; GET_MEMBERSHIP_USING_NUMBER)
    {
        Caption = 'Get membership using query parameters';
    }
    value(101; GET_MEMBERSHIP_USING_ID)
    {
        Caption = 'Get membership using path parameters';
    }

    value(102; BLOCK_MEMBERSHIP)
    {
        Caption = 'Block a membership';
    }
    value(103; UNBLOCK_MEMBERSHIP)
    {
        Caption = 'Unblock a membership';
    }

    value(104; GET_MEMBERSHIP_MEMBERS)
    {
        Caption = 'Get membership members';
    }


    value(110; CREATE_MEMBERSHIP)
    {
        Caption = 'Create a new membership';
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


    value(300; FIND_MEMBER)
    {
        Caption = 'Get member using query parameters';
    }

    value(301; GET_MEMBER_USING_ID)
    {
        Caption = 'Get member using member id';
    }

    value(302; BLOCK_MEMBER)
    {
        Caption = 'Block a member';
    }

    value(303; UNBLOCK_MEMBER)
    {
        Caption = 'Unblock a member';
    }

    value(304; GET_MEMBER_IMAGE)
    {
        Caption = 'Get member image';
    }

    value(305; SET_MEMBER_IMAGE)
    {
        Caption = 'Set member image';
    }

    value(306; ADD_MEMBER)
    {
        Caption = 'Add a new member';
    }

    value(307; UPDATE_MEMBER)
    {
        Caption = 'Update a member';
    }

    value(308; GET_MEMBER_NOTES)
    {
        Caption = 'Get member notes';
    }

    value(309; ADD_MEMBER_NOTE)
    {
        Caption = 'Add member note';
    }

    value(320; GET_CARD_USING_ID)
    {
        Caption = 'Get card using card id';
    }
    value(321; FIND_MEMBER_CARD)
    {
        Caption = 'Find card using card number';
    }
    value(322; ADD_CARD)
    {
        Caption = 'Add a new card';
    }
    value(323; REPLACE_CARD)
    {
        Caption = 'Replace a card';
    }

    value(324; BLOCK_CARD)
    {
        Caption = 'Block a card';
    }
    value(325; UNBLOCK_CARD)
    {
        Caption = 'Unblock a card';
    }

    value(326; REGISTER_ARRIVAL)
    {
        Caption = 'Register arrival';
    }

    value(327; SEND_TO_WALLET)
    {
        Caption = 'Send to wallet';
    }

    value(400; GET_RENEWAL_OPTIONS)
    {
        Caption = 'Get renewal options';
    }
    value(401; GET_EXTEND_OPTIONS)
    {
        Caption = 'Get extend options';
    }
    value(402; GET_UPGRADE_OPTIONS)
    {
        Caption = 'Get upgrade options';
    }

    value(403; GET_CANCEL_OPTIONS)
    {
        Caption = 'Get cancel options';
    }

    value(405; GET_MEMBERSHIP_TIME_ENTRIES)
    {
        Caption = 'Get membership time entries';
    }
    value(406; ACTIVATE_MEMBERSHIP)
    {
        Caption = 'Activate membership';
    }

    value(410; RENEW_MEMBERSHIP)
    {
        Caption = 'Renew membership';
    }
    value(411; EXTEND_MEMBERSHIP)
    {
        Caption = 'Extend membership';
    }
    value(412; UPGRADE_MEMBERSHIP)
    {
        Caption = 'Upgrade membership';
    }
    value(413; CANCEL_MEMBERSHIP)
    {
        Caption = 'Cancel membership';
    }
    value(414; REGRET_MEMBERSHIP)
    {
        Caption = 'Regret membership';
    }

    value(450; RESOLVE_IDENTIFIER)
    {
        Caption = 'Resolve identifier';
    }
}
#endif