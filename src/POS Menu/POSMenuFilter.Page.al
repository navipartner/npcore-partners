page 6150718 "NPR POS Menu Filter"
{
    // NPR5.33/ANEN  /20170607 CASE 270854 Object created to support function for filtererd menu buttons in transcendance pos.
    // NPR5.41/TSA /20180417 CASE 310137 Added Implied filter group and the current register / unit as option.
    // NPR5.48/TJ  /20181108 CASE 318531 New action GenericFilter and DisplayFilter
    //                                   Hid Table Filter action

    Caption = 'POS Menu Filter';
    DelayedInsert = true;
    PageType = Card;
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
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Active; Active)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group("Run object")
            {
                Caption = 'Run object';
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Object Id"; "Object Id")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Object Name"; "Object Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Run Modal"; "Run Modal")
                {
                    ApplicationArea = All;
                }
            }
            group("Filter record")
            {
                Caption = 'Filter record';
                field("Send Sale POS"; "Send Sale POS")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Send Sale Line POS"; "Send Sale Line POS")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                group("Implied Filters")
                {
                    Caption = 'Implied Filters';
                    field("Current POS Register / Unit"; "Current POS Register / Unit")
                    {
                        ApplicationArea = All;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

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
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;
                ApplicationArea = All;

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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
            }
            action(DisplayFilter)
            {
                Caption = 'Display Filter';
                Image = "Filter";
                ApplicationArea = All;
            }
        }
    }
}

