page 6151600 "NPR NpDc Arch. Coupon Card"
{
    Caption = 'Archived Coupon Card';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR NpDc Arch. Coupon";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014426)
                {
                    ShowCaption = false;
                    field("No."; "No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the No. field';
                    }
                    field("Coupon Type"; "Coupon Type")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Coupon Type field';
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Description field';
                    }
                    field("Discount Type"; "Discount Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Discount Type field';
                    }
                    group(Control6014432)
                    {
                        ShowCaption = false;
                        Visible = ("Discount Type" = 0);
                        field("Discount Amount"; "Discount Amount")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                            ToolTip = 'Specifies the value of the Discount Amount field';
                        }
                    }
                    group(Control6014430)
                    {
                        ShowCaption = false;
                        Visible = ("Discount Type" = 1);
                        field("Discount %"; "Discount %")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                            ToolTip = 'Specifies the value of the Discount % field';
                        }
                        field("Max. Discount Amount"; "Max. Discount Amount")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Max. Discount Amount per Sale';
                        }
                    }
                }
                group(Control6014427)
                {
                    ShowCaption = false;
                    field(Open; Open)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Open field';
                    }
                    field("Remaining Quantity"; "Remaining Quantity")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Remaining Quantity field';
                    }
                }
            }
            group("Issue Coupon")
            {
                Caption = 'Issue Coupon';
                group(Control6014405)
                {
                    ShowCaption = false;
                    field("Issue Coupon Module"; "Issue Coupon Module")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Issue Coupon Module field';
                    }
                }
                group(Control6014435)
                {
                    ShowCaption = false;
                    field("Reference No."; "Reference No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Reference No. field';
                    }
                    field("Customer No."; "Customer No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer No. field';
                    }
                    field("Print Template Code"; "Print Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Print Template Code field';
                    }
                }
            }
            group("Validate")
            {
                Caption = 'Validate';
                group(Control6014416)
                {
                    ShowCaption = false;
                    field("Validate Coupon Module"; "Validate Coupon Module")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Validate Coupon Module field';
                    }
                }
                group(Control6014418)
                {
                    ShowCaption = false;
                    field("Starting Date"; "Starting Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Starting Date field';
                    }
                    field("Ending Date"; "Ending Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ending Date field';
                    }
                }
            }
            group("Apply Discount")
            {
                Caption = 'Apply Discount';
                group(Control6014414)
                {
                    ShowCaption = false;
                    field("Apply Discount Module"; "Apply Discount Module")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Apply Discount Module field';
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Max Use per Sale"; "Max Use per Sale")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Max Use per Sale field';
                    }
                }
                group(Control6014415)
                {
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Arch. Coupon Entries")
            {
                Caption = 'Archived Coupon Entries';
                Image = Entries;
                RunObject = Page "NPR NpDc Arch.Coupon Entries";
                RunPageLink = "Arch. Coupon No." = FIELD("No.");
                ShortCutKey = 'Ctrl+F7';
                ApplicationArea = All;
                ToolTip = 'Executes the Archived Coupon Entries action';
            }
        }
    }
}

