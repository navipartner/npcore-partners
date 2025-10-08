table 6151243 "NPR MM Membership Entry Link"
{
    Access = Internal;
    Caption = 'MM Membership Entry Link';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Membership Entry No."; Integer)
        {
            Caption = 'Membership Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Entry"."Entry No.";
        }
        field(20; Context; Option)
        {
            Caption = 'Context';
            DataClassification = CustomerContent;
            OptionCaption = 'New,Regret,Renew,Upgrade,Extend,List,Cancel,Auto-Renew,Foreign Membership,Print Card,Print Member,Print Membership';
            OptionMembers = NEW,REGRET,RENEW,UPGRADE,EXTEND,LIST,CANCEL,AUTORENEW,FOREIGN,PRINT_CARD,PRINT_ACCOUNT,PRINT_MEMBERSHIP;
        }
        field(30; "Initial Valid Until Date"; Date)
        {
            Caption = 'Initial Valid Until Date';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2025-10-06';
            ObsoleteReason = 'Replaced by "Context Period Ending Date"';
        }
        field(40; "New Valid Until Date"; Date)
        {
            Caption = 'New Valid Until Date';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2025-10-06';
            ObsoleteReason = 'Replaced by "Context Period Starting Date"';
        }
        field(50; "Document Type"; Integer)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(60; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(70; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
        }
        field(80; "Context Period Starting Date"; Date)
        {
            Caption = 'Context Period Starting Date';
            DataClassification = CustomerContent;
        }
        field(90; "Context Period Ending Date"; Date)
        {
            Caption = 'Context Period Ending Date';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Document Type", "Document No.", "Document Line No.")
        {
        }
        key(Key3; "Membership Entry No.", Context)
        {
        }
    }

    internal procedure CreateMembershipEntryLink(MembershipEntry: Record "NPR MM Membership Entry"; MemberInfoCapture: Record "NPR MM Member Info Capture"; EndDateNew: Date)
    var
        MembershipEntryLink: Record "NPR MM Membership Entry Link";
        DocumentNo: Code[20];
        DocumentLineNo: Integer;
        DocumentType: Integer;
    begin
        if not GetDocumentKeys(DocumentType, DocumentNo, DocumentLineNo, MemberInfoCapture) then
            exit;
        MembershipEntryLink.SetCurrentKey("Document Type", "Document No.", "Document Line No.");
        MembershipEntryLink.SetRange("Document Type", DocumentType);
        MembershipEntryLink.SetRange("Document No.", DocumentNo);
        MembershipEntryLink.SetRange("Document Line No.", DocumentLineNo);
        if not MembershipEntryLink.FindFirst() then begin
            MembershipEntryLink.Init();
            MembershipEntryLink."Entry No." := 0;
            MembershipEntryLink."Document Type" := DocumentType;
            MembershipEntryLink."Document No." := DocumentNo;
            MembershipEntryLink."Document Line No." := DocumentLineNo;
            MembershipEntryLink.Insert();
        end;
        MembershipEntryLink."Membership Entry No." := MembershipEntry."Entry No.";
        MembershipEntryLink.Context := MemberInfoCapture."Information Context";
        case MembershipEntryLink.Context of
            MembershipEntryLink.Context::CANCEL:
                begin
                    MembershipEntryLink."Context Period Starting Date" := EndDateNew;
                    MembershipEntryLink."Context Period Ending Date" := MembershipEntry."Valid Until Date";
                end;
            MembershipEntryLink.Context::REGRET:
                SetRegretDeferralPeriodDates(MembershipEntryLink);
        end;
        MembershipEntryLink.Modify();
    end;

    local procedure SetRegretDeferralPeriodDates(var MembershipEntryLink: Record "NPR MM Membership Entry Link")
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipEntryLink2: Record "NPR MM Membership Entry Link";
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        InitialValidUntilDate: Date;
    begin
        MembershipEntryLink2.SetCurrentKey("Membership Entry No.", Context);
        MembershipEntryLink2.SetRange("Membership Entry No.", MembershipEntryLink."Membership Entry No.");
        MembershipEntryLink2.SetFilter(Context, '<>%1', MembershipEntryLink2.Context::REGRET);
        MembershipEntryLink2.SetFilter("Entry No.", '<%1', MembershipEntryLink."Entry No.");
        MembershipEntryLink2.SetLoadFields("Context Period Starting Date", "Context Period Ending Date");
        if MembershipEntryLink2.FindLast() then begin
            // We found the latest Cancel
            if MembershipEntryLink2."Context Period Starting Date" <> 0D then
                MembershipEntryLink."Context Period Starting Date" := MembershipEntryLink2."Context Period Starting Date";
            if MembershipEntryLink2."Context Period Ending Date" <> 0D then
                MembershipEntryLink."Context Period Ending Date" := MembershipEntryLink2."Context Period Ending Date";
        end else begin
            MembershipEntry.SetLoadFields("Valid From Date");
            if MembershipEntry.Get(MembershipEntryLink."Membership Entry No.") then begin
                if MembershipEntry."Valid From Date" <> 0D then
                    MembershipEntryLink."Context Period Starting Date" := MembershipEntry."Valid From Date";
                InitialValidUntilDate := MembershipMgtInternal.GetUpgradeInitialValidUntilDate(MembershipEntry."Entry No.");
                if InitialValidUntilDate <> 0D then
                    MembershipEntryLink."Context Period Ending Date" := InitialValidUntilDate;
            end;
        end;
    end;

    local procedure GetDocumentKeys(var DocumentType: Integer; var DocumentNo: Code[20]; var DocumentLineNo: Integer; MemberInfoCapture: Record "NPR MM Member Info Capture") Success: Boolean
    begin
        Success := MemberInfoCapture."Receipt No." <> '';
        if not Success then
            exit;

        DocumentType := Database::"NPR POS Entry Sales Line";
        DocumentNo := MemberInfoCapture."Receipt No.";
        DocumentLineNo := MemberInfoCapture."Line No.";
    end;
}
