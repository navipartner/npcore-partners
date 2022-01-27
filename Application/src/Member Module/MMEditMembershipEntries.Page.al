page 6059844 "NPR MM Edit Membership Entries"
{
    Extensible = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR MM Membership Entry";
    Caption = 'Edit Membership Ledger Entries';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    layout
    {
        area(Content)
        {

            repeater(GroupName)
            {
                field("Entry No.";
                Rec."Entry No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Membership Entry No. field.';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ToolTip = 'Specifies the value of the Membership Code field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Activate On First Use"; Rec."Activate On First Use")
                {
                    ToolTip = 'Specifies the value of the Activate On First Use field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ToolTip = 'Specifies the value of the Valid From Date field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Valid Until Date"; Rec."Valid Until Date")
                {
                    ToolTip = 'Specifies the value of the Valid Until Date field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Created At"; Rec."Created At")
                {
                    ToolTip = 'Specifies the value of the Created At field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("Duration Dateformula"; Rec."Duration Dateformula")
                {
                    ToolTip = 'Specifies the value of the Duration Dateformula field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Amount Incl VAT"; Rec."Amount Incl VAT")
                {
                    ToolTip = 'Specifies the value of the Amount Incl VAT field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the value of the Unit Price field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Unit Price (Base)"; Rec."Unit Price (Base)")
                {
                    ToolTip = 'Specifies the value of the Unit Price (Base) field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field(Context; Rec.Context)
                {
                    ToolTip = 'Specifies the value of the Context field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Original Context"; Rec."Original Context")
                {
                    ToolTip = 'Specifies the value of the Original Context field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ToolTip = 'Specifies the value of the Document Line No. field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ToolTip = 'Specifies the value of the Receipt No. field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Blocked At"; Rec."Blocked At")
                {
                    ToolTip = 'Specifies the value of the Blocked At field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Blocked By"; Rec."Blocked By")
                {
                    ToolTip = 'Specifies the value of the Blocked By field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Auto-Renew Entry No."; Rec."Auto-Renew Entry No.")
                {
                    ToolTip = 'Specifies the value of the Auto-Renew Entry No. field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Closed By Entry No."; Rec."Closed By Entry No.")
                {
                    ToolTip = 'Specifies the value of the Closed By Entry No. field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Import Entry Document ID"; Rec."Import Entry Document ID")
                {
                    ToolTip = 'Specifies the value of the Import Entry Document ID field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Member Card Entry No."; Rec."Member Card Entry No.")
                {
                    ToolTip = 'Specifies the value of the Member Card Entry No. field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ToolTip = 'Specifies the value of the Source Type field.';
                    ApplicationArea = NPRRetail;
                    Editable = ListIsEditable;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(SystemId; Rec.SystemId)
                {
                    ToolTip = 'Specifies the value of the SystemId field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
            }
        }
    }

    var
        [InDataSet]
        ListIsEditable: Boolean;

    trigger OnInit()
    var
        UserSetup: Record "User Setup";
    begin
        if (not UserSetup.Get(CopyStr(UserId, 1, MaxStrLen(UserSetup."User ID")))) then
            UserSetup.Init();

        ListIsEditable := UserSetup."NPR MM Allow MS Entry Edit";

    end;
}