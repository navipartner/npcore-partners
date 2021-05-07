page 6014559 "NPR MM Select Alteration"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR MM Membership Entry";
    SourceTableTemporary = true;
    Editable = false;
    Caption = 'Select Alteration';
    DataCaptionExpression = _LookupCaption;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid From Date field';
                }
                field("Valid Until Date"; Rec."Valid Until Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid Until Date field';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Amount Incl VAT"; Rec."Amount Incl VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Incl VAT field';
                }
            }
        }
    }

    var
        _LookupCaption: Text;

    procedure LoadAlterationOption(LookupCaption: Text; var TmpMembershipEntry: Record "NPR MM Membership Entry" temporary)
    begin
        _LookupCaption := LookupCaption;
        Rec.Copy(TmpMembershipEntry, true);
    end;

}