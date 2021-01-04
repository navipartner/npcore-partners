page 6014660 "NPR Close Navision"
{
    // //Close the navision
    // NPR5.40/TJ  /20180320 CASE 308389 Removed unused variables

    Caption = 'Account is Locked';
    Editable = false;

    layout
    {
        area(content)
        {
            group(Control6150613)
            {
                ShowCaption = false;
                field(errorMessage; errorMessage)
                {
                    ApplicationArea = All;
                    Editable = false;
                    MultiLine = true;
                    Style = StrongAccent;
                    StyleExpr = TRUE;
                    Width = 200;
                    ToolTip = 'Specifies the value of the errorMessage field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnClosePage()
    begin
        StopSession(SessionId);
    end;

    trigger OnInit()
    begin
        errorMessage := ErrorText;
    end;

    var
        errorMessage: Text[250];
        ErrorText: Label 'Your Account is Locked.\Please Contact Navi Partner for more information. \Press "Close" to close the Navision';
}

