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

            trigger OnValidate()
            begin
                if (Rec.Status = Rec.Status::Archived) and (Rec.Default) then
                    Rec.Default := false;
            end;
        }
        field(4; Default; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
            begin
                if (not Rec.Default) then
                    exit;

                MembershipPmtMethodMap.SetRange(MembershipId, Rec.MembershipId);
                MembershipPmtMethodMap.SetFilter(PaymentMethodId, '<>%1', Rec.PaymentMethodId); // Don't include self
                MembershipPmtMethodMap.ModifyAll(Default, false);
            end;
        }
    }

    keys
    {
        key(PK; PaymentMethodId, MembershipId)
        {
            Clustered = true;
        }

        key(MembershipIdx; MembershipId)
        {
        }
    }
}