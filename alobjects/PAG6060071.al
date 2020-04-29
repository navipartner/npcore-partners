page 6060071 "MM Membership Auto Renew Card"
{
    // MM1.22/NPKNAV/20170914  CASE 286922 Transport MM1.22 - 13 September 2017
    // MM1.25/NPKNAV/20180122  CASE 301463 Transport MM1.25 - 22 January 2018

    Caption = 'Membership Auto Renew Card';
    PageType = Card;
    SourceTable = "MM Membership Auto Renew";

    layout
    {
        area(content)
        {
            group(Selection)
            {
                Editable = AllowEdit;
                field("Community Code";"Community Code")
                {
                }
                field("Membership Code";"Membership Code")
                {
                }
                field("Valid Until Date";"Valid Until Date")
                {
                }
                field("Keep Auto-Renew Entries";"Keep Auto-Renew Entries")
                {
                }
            }
            group(Invoicing)
            {
                Editable = AllowEdit;
                field("Document Date";"Document Date")
                {
                    ShowMandatory = true;
                }
                field("Payment Terms Code";"Payment Terms Code")
                {
                    ShowMandatory = true;
                }
                field("Due Date Calculation";"Due Date Calculation")
                {
                }
                field("Payment Method Code";"Payment Method Code")
                {
                    ShowMandatory = true;
                }
                field("Salesperson Code";"Salesperson Code")
                {
                    ShowMandatory = true;
                }
                field("Post Invoice";"Post Invoice")
                {
                }
                field("Posting Date Calculation";"Posting Date Calculation")
                {
                }
                field("Posting Date";"Posting Date")
                {
                }
            }
            group(Statistics)
            {
                field("Started At";"Started At")
                {
                    Editable = false;
                }
                field("Completed At";"Completed At")
                {
                    Editable = false;
                }
                field("Started By";"Started By")
                {
                    Editable = false;
                }
                field("Selected Membership Count";"Selected Membership Count")
                {
                    Editable = false;
                }
                field("Auto-Renew Success Count";"Auto-Renew Success Count")
                {
                    Editable = false;
                }
                field("Auto-Renew Fail Count";"Auto-Renew Fail Count")
                {
                    Editable = false;
                }
                field("Invoice Create Fail Count";"Invoice Create Fail Count")
                {
                    Editable = false;
                }
                field("Invoice Posting Fail Count";"Invoice Posting Fail Count")
                {
                    Editable = false;
                }
                field("First Invoice No.";"First Invoice No.")
                {
                    Editable = false;
                }
                field("Last Invoice No.";"Last Invoice No.")
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        AutoRenewCompleted := ("Completed At" <> CreateDateTime (0D,0T));
        AllowEdit := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Document Date" := CalcDate ('<CM+1D>', Today);
        "Post Invoice" := true;
        "Posting Date" := CalcDate ('<CM+1D>', Today);
        "Valid Until Date" := CalcDate ('<CM>', "Document Date");
        AllowEdit := true;
    end;

    var
        AutoRenewCompleted: Boolean;
        AllowEdit: Boolean;
}

