page 6151393 "CS Store Users"
{
    // NPR5.51/CLVA  /20190813  CASE 365659 Object created - NP Capture Service

    Caption = 'CS Store Users';
    PageType = List;
    SourceTable = "CS Store Users";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User ID";"User ID")
                {
                }
                field("POS Store";"POS Store")
                {
                }
                field(Supervisor;Supervisor)
                {
                }
            }
        }
    }

    actions
    {
    }
}

