page 6185112 "NPR (Dragonglass) Tmp1"
{
    Extensible = False;
    Caption = '[Testing purposes only] : AL Code removed';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            usercontrol(Framework; "NPR Dragonglass")
            {
                ApplicationArea = NPRRetail;

                trigger InvokeMethod(requestId: Integer; method: Text; parameters: JsonObject)

                begin

                end;
            }
        }
    }

    trigger OnOpenPage()

    begin

    end;


    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    begin

    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    begin

    end;


}

