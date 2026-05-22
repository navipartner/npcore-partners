page 6150946 "NPR NPRE Seating Location Card"
{
    Extensible = False;
    Caption = 'Seating Location';
    PageType = Card;
    SourceTable = "NPR NPRE Seating Location";
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies a code to identify this seating location.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the seating location.';
                    ApplicationArea = NPRRetail;
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies the restaurant this seating location belongs to.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store"; Rec."POS Store")
                {
                    ToolTip = 'Specifies the POS store this seating location belongs to.';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Send Kitchen Order"; Rec."Auto Send Kitchen Order")
                {
                    ToolTip = 'Specifies if system should automatically create or update kitchen orders as soon as new products are saved to waiter pads.';
                    ApplicationArea = NPRRetail;
                }
                field("Resend All On New Lines"; Rec."Resend All On New Lines")
                {
                    ToolTip = 'Specifies whether to resend all lines when new lines are added to a waiter pad.';
                    ApplicationArea = NPRRetail;
                }
                field("Send by Print Category"; Rec."Send by Print Category")
                {
                    ToolTip = 'Specifies if kitchen orders should be split by print category.';
                    ApplicationArea = NPRRetail;
                }
                field("Default Number of Guests"; Rec."Default Number of Guests")
                {
                    ToolTip = 'Specifies the default number of guests when a new waiter pad is created for the seating location. <Default> means that the value is inherited from the restaurant the seating location belongs to.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [Action::OK, Action::LookupOK] then begin
            Rec.TestField(Code);
            Rec.TestField("Restaurant Code");
        end;
        exit(true);
    end;
}
