page 6151015 "NPR NpRv Vouchers"
{
    Caption = 'Retail Vouchers';
    CardPageID = "NPR NpRv Voucher Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpRv Voucher";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Voucher Type"; Rec."Voucher Type")
                {

                    ToolTip = 'Specifies the value of the Voucher Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Issue Date"; Rec."Issue Date")
                {

                    ToolTip = 'Specifies the value of the Issue Date field';
                    ApplicationArea = NPRRetail;
                }
                field(Open; Rec.Open)
                {

                    ToolTip = 'Specifies the value of the Open field';
                    ApplicationArea = NPRRetail;
                }
                field("Initial Amount"; Rec."Initial Amount")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Initial Amount field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Date"; Rec."Starting Date")
                {

                    ToolTip = 'Specifies the value of the Starting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Date"; Rec."Ending Date")
                {

                    ToolTip = 'Specifies the value of the Ending Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Reference No."; Rec."Reference No.")
                {

                    ToolTip = 'Specifies the value of the Reference No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Issue Register No."; Rec."Issue Register No.")
                {

                    ToolTip = 'Specifies the value of the Issue Register No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Issue Document Type"; Rec."Issue Document Type")
                {

                    ToolTip = 'Specifies the value of the Issue Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Issue Document No."; Rec."Issue Document No.")
                {

                    ToolTip = 'Specifies the value of the Issue Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Issue External Document No."; Rec."Issue External Document No.")
                {

                    ToolTip = 'Specifies the value of the Issue External Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Issue User ID"; Rec."Issue User ID")
                {

                    ToolTip = 'Specifies the value of the Issue User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Issue Partner Code"; Rec."Issue Partner Code")
                {

                    ToolTip = 'Specifies the value of the Issue Partner Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Partner Clearing"; Rec."Partner Clearing")
                {

                    ToolTip = 'Specifies the value of the Partner Clearing field';
                    ApplicationArea = NPRRetail;
                }
                field("No. Send"; Rec."No. Send")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the No. Send field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(ArchiveGroup)
            {
                Caption = '&Archive';
                Image = Post;
                action("Arch. Vouchers")
                {
                    Caption = 'Archive Vouchers';
                    Image = Post;

                    ToolTip = 'Executes the Archive Vouchers action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        Voucher: Record "NPR NpRv Voucher";
                        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(Voucher);
                        if not Confirm(Text000, false, Voucher.Count) then
                            exit;

                        NpRvVoucherMgt.ArchiveVouchers(Voucher);
                    end;
                }
                action("Show Expired Vouchers")
                {
                    Caption = 'Show Expired Vouchers';
                    Image = "Filter";

                    ToolTip = 'Executes the Show Expired Vouchers action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.SetFilter("Ending Date", '<%1', CurrentDateTime);
                    end;
                }
            }
        }
        area(navigation)
        {
            action("Voucher Entries")
            {
                Caption = 'Voucher Entries';
                Image = Entries;
                RunObject = Page "NPR NpRv Voucher Entries";
                RunPageLink = "Voucher No." = FIELD("No.");
                ShortCutKey = 'Ctrl+F7';

                ToolTip = 'Executes the Voucher Entries action';
                ApplicationArea = NPRRetail;
            }
            action("Sending Log")
            {
                Caption = 'Sending Log';
                Image = Log;
                RunObject = Page "NPR NpRv Sending Log";
                RunPageLink = "Voucher No." = FIELD("No.");
                ShortCutKey = 'Shift+Ctrl+F7';

                ToolTip = 'Executes the Sending Log action';
                ApplicationArea = NPRRetail;
            }
            action("Show Archived Vouchers")
            {
                Caption = 'Show Archived Vouchers';
                Image = PostedPutAway;
                RunObject = Page "NPR NpRv Arch. Vouchers";

                ToolTip = 'Executes the Show Archived Vouchers action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    var
        Text000: Label 'Archive %1 selected Vouchers Manually?';
}

