page 6014559 "NPR MM Select Alteration"
{
    Extensible = False;
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

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Valid From Date"; Rec."Valid From Date")
                {

                    ToolTip = 'Specifies the value of the Valid From Date field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Valid Until Date"; Rec."Valid Until Date")
                {

                    ToolTip = 'Specifies the value of the Valid Until Date field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Unit Price"; Rec."Unit Price")
                {

                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Amount Incl VAT"; Rec."Amount Incl VAT")
                {

                    ToolTip = 'Specifies the value of the Amount Incl VAT field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    var
        _LookupCaption: Text;

    internal procedure LoadAlterationOption(LookupCaption: Text; var TmpMembershipEntry: Record "NPR MM Membership Entry" temporary)
    begin
        _LookupCaption := LookupCaption;
        Rec.Copy(TmpMembershipEntry, true);
    end;

}
