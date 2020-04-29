page 6151372 "CS Communication Log List"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018

    Caption = 'CS Communication Log List';
    CardPageID = "CS Communication Log Card";
    Editable = false;
    PageType = List;
    SourceTable = "CS Communication Log";
    SourceTableView = SORTING("Request Start")
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id;Id)
                {
                }
                field("Request Start";"Request Start")
                {
                }
                field("Request End";"Request End")
                {
                }
                field("Request Function";"Request Function")
                {
                }
                field("Internal Request";"Internal Request")
                {
                }
                field("Internal Log No.";"Internal Log No.")
                {
                }
                field(User;User)
                {
                }
            }
        }
    }

    actions
    {
    }
}

