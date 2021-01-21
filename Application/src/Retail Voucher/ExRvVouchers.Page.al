page 6151081 "NPR ExRv Vouchers"
{
    Caption = 'External Retail Vouchers';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR ExRv Voucher";

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
                    ToolTip = 'Specifies the value of the Voucher Type field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Issued at"; "Issued at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issued at field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field(Posted; Posted)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posted field';
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open field';
                }
                field("Remaining Amount"; "Remaining Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remaining Amount field';
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Source Table No. field';
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source No. field';
                }
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference No. field';
                }
                field("Online Reference No."; "Online Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Online Reference No. field';
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Post Selected action';
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;

                trigger OnAction()
                var
                    ExRvVoucher: Record "NPR ExRv Voucher";
                    ExRvMgt: Codeunit "NPR ExRv Mgt.";
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
				PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Executes the &Navigate action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Dimensions action';

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

