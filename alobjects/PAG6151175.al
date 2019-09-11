page 6151175 "NpGp Cross Companies Setup"
{
    // NPR5.51/ALST/20190422 CASE 337539 New object

    Caption = 'Cross Companies Setup';
    PageType = List;
    SourceTable = "NpGp Cross Company Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Original Company";"Original Company")
                {
                }
                field("Location Code";"Location Code")
                {
                }
                field("Gen. Bus. Posting Group";"Gen. Bus. Posting Group")
                {
                }
                field("Generic Item No.";"Generic Item No.")
                {
                }
                field(Customer;Customer)
                {
                }
                field("Use Original Item No.";"Use Original Item No.")
                {
                }
            }
        }
    }

    actions
    {
    }
}

