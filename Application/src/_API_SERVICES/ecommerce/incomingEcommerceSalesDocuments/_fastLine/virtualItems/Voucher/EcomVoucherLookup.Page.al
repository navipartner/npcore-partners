#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page 6150935 "NPR Ecom Voucher Lookup"
{
    Caption = 'Vouchers';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR NpRv Voucher";
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    ApplicationArea = NPRRetail;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _RowStyle;
                    ToolTip = 'Specifies the voucher number.';
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _RowStyle;
                    ToolTip = 'Specifies the voucher reference number presented to the customer.';
                }
                field("Voucher Type"; Rec."Voucher Type")
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _RowStyle;
                    ToolTip = 'Specifies the voucher type.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _RowStyle;
                    ToolTip = 'Specifies the voucher description. Archived vouchers are prefixed with [Archived].';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _RowStyle;
                    ToolTip = 'Specifies when the voucher became valid.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _RowStyle;
                    ToolTip = 'Specifies when the voucher expires.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenVoucher)
            {
                Caption = 'Open';
                ApplicationArea = NPRRetail;
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Open the selected voucher (live or archived).';

                trigger OnAction()
                var
                    EcomCreateVchrImpl: Codeunit "NPR EcomCreateVchrImpl";
                begin
                    EcomCreateVchrImpl.OpenVoucherCardForSystemId(Rec.SystemId);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        EcomCreateVchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        if EcomCreateVchrImpl.IsArchivedTempDescription(Rec.Description) then
            _RowStyle := 'Subordinate'
        else
            _RowStyle := 'Standard';
    end;

    var
        _RowStyle: Text;
}
#endif
