page 6151080 "ExRv Voucher Types"
{
    // NPR5.40/MHA /20180212  CASE 301346 Object created - External Retail Voucher

    Caption = 'External Retail Voucher Types';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "ExRv Voucher Type";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Account No."; "Account No.")
                {
                    ApplicationArea = All;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = All;
                }
                field("Direct Posting"; "Direct Posting")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Remaining Amount"; "Remaining Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Update Voucher Status")
            {
                Caption = 'Update Voucher Status';
                Image = RefreshVoucher;

                trigger OnAction()
                var
                    ExRvMgt: Codeunit "ExRv Management";
                begin
                    ExRvMgt.UpdateIsOpenVouchers(Rec);
                end;
            }
        }
        area(navigation)
        {
            action(Vouchers)
            {
                Caption = 'Vouchers';
                Image = Voucher;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "ExRv Vouchers";
                RunPageLink = "Voucher Type" = FIELD(Code);
                ShortCutKey = 'Ctrl+F7';
            }
            action(Dimensions)
            {
                AccessByPermission = TableData Dimension = R;
                Caption = 'Dimensions';
                Image = Dimensions;
                ShortCutKey = 'Shift+Ctrl+D';

                trigger OnAction()
                begin
                    ShowDocDim;
                    CurrPage.SaveRecord;
                end;
            }
        }
    }
}

