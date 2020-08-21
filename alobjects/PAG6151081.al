page 6151081 "ExRv Vouchers"
{
    // NPR5.40/MHA /20180212  CASE 301346 Object created - External Retail Voucher

    Caption = 'External Retail Vouchers';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "ExRv Voucher";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Voucher Type"; "Voucher Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Issued at"; "Issued at")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field(Posted; Posted)
                {
                    ApplicationArea = All;
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                }
                field("Remaining Amount"; "Remaining Amount")
                {
                    ApplicationArea = All;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = All;
                }
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = All;
                }
                field("Online Reference No."; "Online Reference No.")
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
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Post Selected")
            {
                Caption = 'Post Selected';
                Image = Post;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;

                trigger OnAction()
                var
                    ExRvVoucher: Record "ExRv Voucher";
                    ExRvMgt: Codeunit "ExRv Management";
                begin
                    CurrPage.SetSelectionFilter(ExRvVoucher);
                    ExRvVoucher.FilterGroup(30);
                    ExRvVoucher.SetRange(Posted, false);
                    if not Confirm(Text000, true, ExRvVoucher.Count) then
                        exit;

                    ExRvMgt.PostVouchers(ExRvVoucher);
                    Message(Text001);
                end;
            }
        }
        area(navigation)
        {
            action(Navigate)
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Navigate.SetDoc("Posting Date", "Source No.");
                    Navigate.Run;
                end;
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

    var
        Text000: Label 'Post %1 unposted Vouchers?';
        Text001: Label 'Vouchers posted';
        Navigate: Page Navigate;
}

