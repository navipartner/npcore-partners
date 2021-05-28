codeunit 85037 "NPR Test Fixture"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Test Initialize", 'OnBeforeTestSuiteInitialize', '', false, false)]
    local procedure OnBeforeTestSuiteInitialize(CallerCodeunitID: Integer)
    begin
        GlobalLanguage(1033); // standard tests are expected to run with application language set to ENU, but some switch to local language if available
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Test Initialize", 'OnAfterTestSuiteInitialize', '', false, false)]
    local procedure OnAfterTestSuiteInitialize(CallerCodeunitID: Integer)
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Test Initialize", 'OnTestInitialize', '', false, false)]
    local procedure OnTestInitialize(CallerCodeunitID: Integer)
    begin

    end;
}
