pageextension 6014414 "NPR My Job Queue" extends "My Job Queue"
{
    actions
    {
        addfirst(processing)
        {
            action("NPR ShowAllEntries")
            {
                Caption = 'Show All Jobs';
                ToolTip = 'Display all job queue entries regardless of the user, who has scheduled the job';
                Visible = not AllJobs;
                Image = ClearFilter;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.SetRange("User ID");
                    UpdateVisibility();
                end;
            }
            action("NPR ShowOnlyMy")
            {
                Caption = 'Show Only My Jobs';
                ToolTip = 'Display only my job queue entries';
                Visible = AllJobs;
                Image = ShowSelected;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.SetRange("User ID", UserId);
                    UpdateVisibility();
                end;
            }
        }
    }

    var
        AllJobs: Boolean;

    trigger OnOpenPage()
    begin
        UpdateVisibility();
    end;

    local procedure UpdateVisibility()
    begin
        AllJobs := Rec.GetFilter("User ID") = '';
    end;
}