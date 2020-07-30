page 6151331 "NP Retail Legal Page"
{
    Caption = 'Legal Page';
    PageType = List;
    SourceTable = "NP Retail Setup";
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Standard Conditions"; "Standard Conditions")
                {

                }
                field("License Agreement"; "License Agreement")
                {

                }
                field(Privacy; Privacy)
                {

                }
            }
        }

    }
}