codeunit 6060008 "GIM - Data Create Test"
{
    // NPR5.40/TS  /20180320 CASE 308380 Added text Value to text constant MsgTDC

    Subtype = Test;

    trigger OnRun()
    begin
    end;

    var
        ImpDoc: Record "GIM - Import Document";
        ImpDocNo: Code[20];
        DataCreationCodeunit: Codeunit "GIM - Data Creation";
        Text001: Label 'Used so Handler functions have at least 1 check to perform as it would otherwise fail.';

    [Test]
    [HandlerFunctions('MyConfirmHandler')]
    procedure CreateData()
    begin
        ImpDoc.Get(ImpDocNo);
        DataCreationCodeunit.Run(ImpDoc);
        if Confirm(Text001) then;
    end;

    procedure SetImpDoc(ImpDocNoHere: Code[20])
    begin
        ImpDocNo := ImpDocNoHere;
    end;

    [ConfirmHandler]
    procedure MyConfirmHandler(Question: Text[1024];var Reply: Boolean)
    var
        MsgTDC: Label 'Use TDC tunnel for Customer search?';
    begin
        case Question of
          MsgTDC: Reply := false;
          else
            Reply := true;
        end;
    end;
}

