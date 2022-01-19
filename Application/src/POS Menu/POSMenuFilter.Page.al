page 6150718 "NPR POS Menu Filter"
{
    Caption = 'POS Menu Filter';
    DelayedInsert = true;
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR POS Menu Filter";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Filter Code"; Rec."Filter Code")
                {

                    ToolTip = 'Specifies the value of the Filter Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Active; Rec.Active)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Active field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Run object")
            {
                Caption = 'Run object';
                field("Object Type"; Rec."Object Type")
                {

                    ToolTip = 'Specifies the value of the Object Type field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Object Id"; Rec."Object Id")
                {

                    ToolTip = 'Specifies the value of the Object Id field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Object Name"; Rec."Object Name")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Object Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Run Modal"; Rec."Run Modal")
                {

                    ToolTip = 'Specifies the value of the Run Modal field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Filter record")
            {
                Caption = 'Filter record';
                field("Send Sale POS"; Rec."Send Sale POS")
                {

                    ToolTip = 'Specifies the value of the Send Sale POS field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Send Sale Line POS"; Rec."Send Sale Line POS")
                {

                    ToolTip = 'Specifies the value of the Send Sale Line POS field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Table Name"; Rec."Table Name")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRRetail;
                }
                group("Implied Filters")
                {
                    Caption = 'Implied Filters';
                    field("Current POS Register / Unit"; Rec."Current POS Register / Unit")
                    {

                        ToolTip = 'Specifies the value of the Current POS Register / Unit field';
                        ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Test & Activate action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.ActivateFilter();
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

                ToolTip = 'Executes the Deactivate action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.DeActivateFilter();
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

                ToolTip = 'Executes the Table Filter action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.TableFilter();
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

                ToolTip = 'Executes the Generic Filter action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.TableFilter();
                end;
            }
            action(DisplayFilter)
            {
                Caption = 'Display Filter';
                Image = "Filter";

                ToolTip = 'Executes the Display Filter action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    FilterStringText: Text;
                    INS: InStream;
                    NoFilterText: Label 'No filters set.';
                begin
                    FilterStringText := NoFilterText;
                    Rec.CalcFields("Table Filter");
                    if Rec."Table Filter".HasValue then begin
                        Rec."Table Filter".CreateInStream(INS);
                        INS.Read(FilterStringText);
                    end;
                    Message(FilterStringText);
                end;
            }
        }
    }
}

