#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185122 "NPR MembershipApiHandler"
{
    Access = Internal;

    var
        _Response: Codeunit "NPR API Response";
        _Request: Codeunit "NPR API Request";
        _ApiFunction: Enum "NPR MembershipApiFunctions";

    trigger OnRun()
    begin
        HandleFunction();
    end;

    internal procedure SetRequest(ApiFunction: Enum "NPR MembershipApiFunctions"; var Request: Codeunit "NPR API Request")
    var
        ErrorCode: Enum "NPR API Error Code";
        ErrorStatusCode: Enum "NPR API HTTP Status Code";
    begin
        _ApiFunction := ApiFunction;
        _Request := Request;
        _Response.CreateErrorResponse(ErrorCode::resource_not_found, StrSubstNo('The API function %1 is not yet supported.', _ApiFunction), ErrorStatusCode::"Bad Request");
    end;

    internal procedure GetResponse() Response: Codeunit "NPR API Response"
    begin
        Response := _Response;
    end;

    internal procedure HandleFunction()
    var
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
        MemberApiAgent: Codeunit "NPR MemberApiAgent";
        MemberCardApiAgent: Codeunit "NPR MemberCardApiAgent";
        MembershipCatalogAgent: Codeunit "NPR MembershipCatalogAgent";
        MembershipPhasesApiAgent: Codeunit "NPR MembershipPhasesApiAgent";
        MembershipMiscApiAgent: Codeunit "NPR MembershipMiscApiAgent";
        MembershipSubscrApiAgent: Codeunit "NPR MembershipSubscrAgent";
        PaymentMethodApiAgent: Codeunit "NPR API SubscriptionPmtMethods";
        MembershipAttributesAgent: Codeunit "NPR MembershipAttributesAgent";
        LoyaltyApiAgent: Codeunit "NPR LoyaltyApiAgent";
        MembershipListAgent: Codeunit "NPR MembershipListAgent";
    begin
        case _ApiFunction of

            _ApiFunction::GET_CATALOG:
                _Response := MembershipCatalogAgent.GetMembershipCatalog(_Request);



            _ApiFunction::GET_MEMBERSHIP_USING_NUMBER:
                _Response := MembershipApiAgent.GetMembershipByNumber(_Request);

            _ApiFunction::GET_MEMBERSHIP_USING_ID:
                _Response := MembershipApiAgent.GetMembershipById(_Request);

            _ApiFunction::GET_MEMBERSHIP_MEMBERS:
                _Response := MembershipApiAgent.GetMembershipMembers(_Request);

            _ApiFunction::LIST_MEMBERSHIPS:
                _Response := MembershipListAgent.ListMemberships(_Request);

            _ApiFunction::CREATE_MEMBERSHIP:
                _Response := MembershipApiAgent.CreateMembership(_Request);

            _ApiFunction::BLOCK_MEMBERSHIP:
                _Response := MembershipApiAgent.BlockMembership(_Request);

            _ApiFunction::UNBLOCK_MEMBERSHIP:
                _Response := MembershipApiAgent.UnblockMembership(_Request);

            _ApiFunction::GET_MEMBERSHIP_RENEWAL_INFO:
                _Response := MembershipApiAgent.GetMembershipRenewalInfo(_Request);


            _ApiFunction::LIST_MEMBERSHIP_ATTRIBUTES:
                _Response := MembershipAttributesAgent.ListMembershipAttributes(_Request);
            _ApiFunction::GET_MEMBERSHIP_ATTRIBUTE_VALUES:
                _Response := MembershipAttributesAgent.GetMembershipAttributeValues(_Request);
            _ApiFunction::SET_MEMBERSHIP_ATTRIBUTE_VALUES:
                _Response := MembershipAttributesAgent.SetMembershipAttributeValues(_Request);
            _ApiFunction::DELETE_MEMBERSHIP_ATTRIBUTE_VALUES:
                _Response := MembershipAttributesAgent.DeleteMembershipAttributeValues(_Request);


            _ApiFunction::FIND_MEMBER:
                _Response := MemberApiAgent.FindMember(_Request);

            _ApiFunction::GET_MEMBER_USING_ID:
                _Response := MemberApiAgent.GetMemberById(_Request);

            _ApiFunction::BLOCK_MEMBER:
                _Response := MemberApiAgent.BlockMember(_Request);

            _ApiFunction::UNBLOCK_MEMBER:
                _Response := MemberApiAgent.UnblockMember(_Request);

            _ApiFunction::GET_MEMBER_IMAGE:
                _Response := MemberApiAgent.GetMemberImage(_Request);

            _ApiFunction::SET_MEMBER_IMAGE:
                _Response := MemberApiAgent.SetMemberImage(_Request);

            _ApiFunction::ADD_MEMBER:
                _Response := MemberApiAgent.AddMember(_Request);

            _ApiFunction::UPDATE_MEMBER:
                _Response := MemberApiAgent.UpdateMember(_Request);

            _ApiFunction::GET_MEMBER_NOTES:
                _Response := MemberApiAgent.GetMemberNotes(_Request);

            _ApiFunction::ADD_MEMBER_NOTE:
                _Response := MemberApiAgent.AddMemberNote(_Request);

            _ApiFunction::LIST_MEMBER_ATTRIBUTES:
                _Response := MembershipAttributesAgent.ListMemberAttributes(_Request);
            _ApiFunction::GET_MEMBER_ATTRIBUTE_VALUES:
                _Response := MembershipAttributesAgent.GetMemberAttributeValues(_Request);
            _ApiFunction::SET_MEMBER_ATTRIBUTE_VALUES:
                _Response := MembershipAttributesAgent.SetMemberAttributeValues(_Request);
            _ApiFunction::DELETE_MEMBER_ATTRIBUTE_VALUES:
                _Response := MembershipAttributesAgent.DeleteMemberAttributeValues(_Request);

            _ApiFunction::GET_CARD_USING_ID:
                _Response := MemberCardApiAgent.GetMemberCardById(_Request);

            _ApiFunction::FIND_MEMBER_CARD:
                _Response := MemberCardApiAgent.GetMemberCardByNumber(_Request);

            _ApiFunction::BLOCK_CARD:
                _Response := MemberCardApiAgent.BlockMemberCard(_Request);

            _ApiFunction::UNBLOCK_CARD:
                _Response := MemberCardApiAgent.UnblockMemberCard(_Request);

            _ApiFunction::ADD_CARD:
                _Response := MemberCardApiAgent.AddMemberCard(_Request);

            _ApiFunction::REPLACE_CARD:
                _Response := MemberCardApiAgent.ReplaceMemberCard(_Request);

            _ApiFunction::PATCH_CARD:
                _Response := MemberCardApiAgent.PatchMemberCard(_Request);

            _ApiFunction::SEND_TO_WALLET:
                _Response := MemberCardApiAgent.SendToWallet(_Request);


            _ApiFunction::GET_RENEWAL_OPTIONS:
                _Response := MembershipPhasesApiAgent.GetRenewalOptions(_Request);
            _ApiFunction::RENEW_MEMBERSHIP:
                _Response := MembershipPhasesApiAgent.RenewMembership(_Request);

            _ApiFunction::GET_EXTEND_OPTIONS:
                _Response := MembershipPhasesApiAgent.GetExtendOptions(_Request);
            _ApiFunction::EXTEND_MEMBERSHIP:
                _Response := MembershipPhasesApiAgent.ExtendMembership(_Request);

            _ApiFunction::GET_UPGRADE_OPTIONS:
                _Response := MembershipPhasesApiAgent.GetUpgradeOptions(_Request);
            _ApiFunction::UPGRADE_MEMBERSHIP:
                _Response := MembershipPhasesApiAgent.UpgradeMembership(_Request);

            _ApiFunction::GET_CANCEL_OPTIONS:
                _Response := MembershipPhasesApiAgent.GetCancelOptions(_Request);
            _ApiFunction::CANCEL_MEMBERSHIP:
                _Response := MembershipPhasesApiAgent.CancelMembership(_Request);

            _ApiFunction::REGRET_MEMBERSHIP:
                _Response := MembershipPhasesApiAgent.RegretMembership(_Request);

            _ApiFunction::GET_MEMBERSHIP_TIME_ENTRIES:
                _Response := MembershipPhasesApiAgent.GetMembershipTimeEntries(_Request);

            _ApiFunction::GET_MEMBERSHIP_RECEIPT_LIST:
                _Response := MembershipPhasesApiAgent.GetMembershipReceiptList(_Request);

            _ApiFunction::ACTIVATE_MEMBERSHIP:
                _Response := MembershipPhasesApiAgent.ActivateMembership(_Request);


            _ApiFunction::GET_ALL_PAYMENT_METHODS:
                _Response := PaymentMethodApiAgent.GetPaymentMethods(_Request);

            _ApiFunction::CREATE_PAYMENT_METHOD:
                _Response := PaymentMethodApiAgent.CreatePaymentMethod(_Request);

            _ApiFunction::GET_PAYMENT_METHOD:
                _Response := PaymentMethodApiAgent.GetPaymentMethod(_Request);

            _ApiFunction::UPDATE_PAYMENT_METHOD:
                _Response := PaymentMethodApiAgent.UpdatePaymentMethod(_Request);

            _ApiFunction::DELETE_PAYMENT_METHOD:
                _Response := PaymentMethodApiAgent.DeletePaymentMethod(_Request);


            _ApiFunction::RESOLVE_IDENTIFIER:
                _Response := MembershipMiscApiAgent.ResolveIdentifier(_Request);

            _ApiFunction::GET_SUBSCRIPTION:
                _Response := MembershipSubscrApiAgent.GetSubscription(_Request);

            _ApiFunction::ENTER_SUBSCRIPTION:
                _Response := MembershipSubscrApiAgent.EnterSubscription(_Request);

            _ApiFunction::TERMINATE_SUBSCRIPTION:
                _Response := MembershipSubscrApiAgent.TerminateSubscription(_Request);

            _ApiFunction::POINTS_GET_BALANCE:
                _Response := LoyaltyApiAgent.GetMembershipPoints(_Request);
            _ApiFunction::POINTS_RESERVE:
                _Response := LoyaltyApiAgent.CreateReservationTransaction(_Request);
            _ApiFunction::POINTS_CANCEL_RESERVATION:
                _Response := LoyaltyApiAgent.CancelReservationTransaction(_Request);
            _ApiFunction::POINTS_REGISTER_SALE:
                _Response := LoyaltyApiAgent.RegisterSaleTransaction(_Request);
            _ApiFunction::GET_POINTS_TRANSACTIONS:
                _Response := LoyaltyApiAgent.GetMembershipTransactions(_Request);

            _ApiFunction::GET_LOYALTY_TAGS:
                _Response := LoyaltyApiAgent.GetLoyaltyTags(_Request);
            _ApiFunction::CREATE_LOYALTY_TAGS:
                _Response := LoyaltyApiAgent.CreateLoyaltyTags(_Request);
        end;
    end;


}
#endif