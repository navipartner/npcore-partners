pageextension 6248181 "NPR Document Sending Profile" extends "Document Sending Profile"
{
    actions
    {
        addlast(Processing)
        {
            action("NPR NP Email Templates")
            {
                ApplicationArea = NPRRetail;
                Caption = 'NP Email Templates';
                Image = Email;
                Visible = NPEmailFieldsVisible;
                ToolTip = 'Set up which NP Email template is used for each document type.';

                trigger OnAction()
                var
                    DocTmplSelections: Page "NPR NPEmailDocTmplSelections";
                begin
                    DocTmplSelections.RunModal();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        NPEmailFeature: Codeunit "NPR NP Email Feature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        NPEmailFieldsVisible := NPEmailFeature.IsFeatureEnabled() and NewEmailExpFeature.IsFeatureEnabled();
    end;

    var
        NPEmailFieldsVisible: Boolean;
}
