page 6150975 "NPR APIV1 PBI MShipPaymentMap"
{
    Extensible = false;
    Caption = 'PowerBI Membership Payment Methods';
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    EntitySetName = 'membershipPaymentMethods';
    EntityName = 'membershipPaymentMethod';
    PageType = API;
    DataAccessIntent = ReadOnly;
    DelayedInsert = true;
    Editable = false;
    SourceTable = "NPR MM MembershipPmtMethodMap";
    ODataKeyFields = SystemId;


    layout
    {
        area(Content)
        {
            repeater(MembershipPaymentMethodRepeater)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                }
                field(membershipId; Rec.MembershipId)
                {
                    Caption = 'Membership Id', Locked = true;
                }
                field(paymentMethodId; Rec.PaymentMethodId)
                {
                    Caption = 'Payment Method Id', Locked = true;
                }
                field(default; Rec.Default)
                {
                    Caption = 'Default', Locked = true;
                }
#if not (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'System Row Version', Locked = true;
                }
#endif
            }
        }
    }
}
