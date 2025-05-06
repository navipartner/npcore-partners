table 6151174 "NPR MM MembershipPmtMethodMap"
{
    Access = Internal;
    Caption = 'Membership Payment Method Mapping';

    fields
    {
        field(1; PaymentMethodId; Guid)
        {
            Caption = 'Payment Method Id';
            DataClassification = SystemMetadata;
            TableRelation = "NPR MM Member Payment Method".SystemId;
        }
        field(2; MembershipId; Guid)
        {
            Caption = 'Membership Id';
            DataClassification = SystemMetadata;
            TableRelation = "NPR MM Membership".SystemId;
        }
        field(3; Status; Enum "NPR MM Payment Method Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; PaymentMethodId, MembershipId)
        {
            Clustered = true;
        }
    }
}