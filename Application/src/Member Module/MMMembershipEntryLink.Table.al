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
        }
        field(40; "New Valid Until Date"; Date)
        {
            Caption = 'New Valid Until Date';
            DataClassification = CustomerContent;
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
    }
    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Document Type", "Document No.", "Document Line No.")
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
        MembershipEntryLink."Initial Valid Until Date" := MembershipEntry."Valid Until Date";
        MembershipEntryLink."New Valid Until Date" := EndDateNew;
        MembershipEntryLink.Modify();
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
