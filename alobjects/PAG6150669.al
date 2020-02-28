page 6150669 "NPRE Restaurant Setup"
{
    // NPR5.34/ANEN  /2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.41/THRO /20180412 CASE 309873 Replaced 2 template fields by a listpart page for setup of multiple templates

    Caption = 'Restaurant Setup';
    PageType = Card;
    SourceTable = "NPRE Restaurant Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group("Waiter Pad")
            {
                Caption = 'Waiter Pad';
                field("Waiter Pad No. Serie";"Waiter Pad No. Serie")
                {
                }
            }
            group(Print)
            {
                Caption = 'Print';
                field("Auto Print Kitchen Order";"Auto Print Kitchen Order")
                {
                }
            }
            part(Templates;"NPRE Print Templates Subpage")
            {
                Caption = 'Templates';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Print Category")
            {
                Caption = 'Print Category';
                Image = PrintForm;
                RunObject = Page "NPRE Print Categories";
            }
        }
    }
}

