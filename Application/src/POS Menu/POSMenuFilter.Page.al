page 6150718 "NPR POS Menu Filter"
{
    Caption = 'POS Menu Filter';
    DelayedInsert = true;
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Menu Filter";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Filter Code"; "Filter Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Active; Active)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Active field';
                }
            }
            group("Run object")
            {
                Caption = 'Run object';
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object Type field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Object Id"; "Object Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object Id field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Object Name"; "Object Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Object Name field';
                }
                field("Run Modal"; "Run Modal")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Run Modal field';
                }
            }
            group("Filter record")
            {
                Caption = 'Filter record';
                field("Send Sale POS"; "Send Sale POS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Sale POS field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Send Sale Line POS"; "Send Sale Line POS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Sale Line POS field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                group("Implied Filters")
                {
                    Caption = 'Implied Filters';
                    field("Current POS Register / Unit"; "Current POS Register / Unit")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Current POS Register / Unit field';
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Test & Activate")
            {
                Caption = 'Test & Activate';
                Image = ApprovalSetup;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Test & Activate action';

                trigger OnAction()
                begin
                    Rec.ActivateFilter;
                end;
            }
            action(Deactivate)
            {
                Caption = 'Deactivate';
                Image = Cancel;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Deactivate action';

                trigger OnAction()
                begin
                    Rec.DeActivateFilter;
                end;
            }
            action("Table Filter")
            {
                Caption = 'Table Filter';
                Image = EditFilter;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Table Filter action';

                trigger OnAction()
                begin
                    Rec.TableFilter;
                end;
            }
            action(GenericFilter)
            {
                Caption = 'Generic Filter';
                Image = EditFilter;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Generic Filter action';
            }
            action(DisplayFilter)
            {
                Caption = 'Display Filter';
                Image = "Filter";
                ApplicationArea = All;
                ToolTip = 'Executes the Display Filter action';
            }
        }
    }
}

