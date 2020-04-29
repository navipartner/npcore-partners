pageextension 6014426 pageextension6014426 extends "Req. Worksheet" 
{
    // NPR4.04/TS/20150218  CASE 206013 Added FUnction Read From Scanner
    // NPR5.22/TJ20160411 CASE 238601 Moved code from function Read From Scanner to NPR Event Subscriber codeunit
    // NPR5.39/TJ  /20180208  CASE 302634 Renamed Name property of action Read from Scanner to english
    actions
    {
        addafter("Sales &Order")
        {
            action("&ReadFromScanner")
            {
                Caption = 'Read from scanner';
                Promoted = true;
                PromotedCategory = Process;
            }
        }
    }
}

