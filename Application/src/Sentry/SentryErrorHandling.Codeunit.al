#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6184897 "NPR Sentry Error Handling"
{
    Access = Internal;

    internal procedure SplitErrorStacktrace(ErrorStacktrace: Text; var SplitErrorStacktraceList: List of [Text])
    begin
        SplitErrorStacktraceList := ErrorStacktrace.Split('\');
        SplitErrorStacktraceList.Reverse();
    end;

    internal procedure IsLastErrorAProgrammingBug(): Boolean
    var
        PreviousLanguageId: Integer;
        ErrorCode: Text;
        ErrorText: Text;
        Regex: Codeunit Regex;
    begin
        PreviousLanguageId := GlobalLanguage();
        GlobalLanguage(1033); //english
        ErrorCode := GetLastErrorCode();
        ErrorText := GetLastErrorText();
        GlobalLanguage(PreviousLanguageId);

        //This is a manually maintained list of detections for english platform error texts that are programming bugs.
        if ErrorCode.EndsWith('DivideByZero') then
            exit(true);
        if ErrorText.Contains('divided by zero') then
            exit(true);
        if ErrorText.Contains('This is a programming bug') then
            exit(true);
        // TODO: Could be environmental error
        if Regex.IsMatch(ErrorText, 'The activity was deadlocked with another user who was modifying the .* table. Please retry the activity', 0) then
            exit(true);

        // Value Overflow (Integer/Decimal/BigInteger arithmetic overflow)
        if ErrorText.Contains('Arithmetic operation resulted in an overflow') then
            exit(true);

        // JsonObject.Get() and siblings - property not found
        // TODO: Could be user input error if parsing user-provided JSON
        if ErrorText.Contains('does not contain a property with the given key') then
            exit(true);
        if Regex.IsMatch(ErrorText, 'A property with the name .* was not found', 0) then
            exit(true);

        // XmlDocument.SelectNodes and siblings - XML parsing/selection errors
        // TODO: Could be user input error if parsing user-provided XML
        if ErrorText.Contains('has an invalid token') then
            exit(true);
        if ErrorText.Contains('has an invalid qualified name character') then
            exit(true);
        if Regex.IsMatch(ErrorText, 'Namespace prefix .* is not defined', 0) then
            exit(true);

        // Read-Intent Report doing a write
        if ErrorText.Contains('You cannot perform a write transaction from a read-only session') then
            exit(true);
        if ErrorText.Contains('is not allowed in read-only sessions') then
            exit(true);

        // Modal page started in the middle of a transaction
        if ErrorText.Contains('is not allowed in write transactions') then
            exit(true);
        if ErrorText.Contains('RunModal is not allowed in write transactions') then
            exit(true);

        // Codeunit.Run with return value in transaction
        if ErrorText.Contains('Codeunit.Run is allowed in write transactions only if the return value is not used') then
            exit(true);

        // HttpClient timeout
        // TODO: Could be environmental error
        if ErrorText.Contains('The operation has timed out') then
            exit(true);
        if ErrorText.Contains('A connection attempt failed') then
            exit(true);
        if ErrorText.Contains('The request was aborted') then
            exit(true);
        if ErrorCode.EndsWith('NavNclHttpClientTimeoutTooLargeException') then
            exit(true);

        exit(false);
    end;

    procedure GetCurrCallStack() CallStack: Text;
    begin
        if ThrowError() then;
        CallStack := GetLastErrorCallStack();
        CallStack := RemoveLocalFunctionsFromCallStack(CallStack, '"NPR Sentry Span"(CodeUnit 6248498)');
        CallStack := RemoveLocalFunctionsFromCallStack(CallStack, '"NPR Sentry Scope"(CodeUnit 6150994)');
    end;

    local procedure RemoveLocalFunctionsFromCallStack(CallStack: Text; ObjectSubstring: Text): Text;
    var
        Len: Integer;
        Pos: Integer;
    begin
        Len := StrLen(ObjectSubstring);
        Pos := StrPos(CallStack, ObjectSubstring);
        while Pos > 0 do begin
            CallStack := CopyStr(CallStack, Pos + Len);
            Pos := StrPos(CallStack, ObjectSubstring);
        end;
        Pos := StrPos(CallStack, '\');
        if Pos > 0 then
            exit(CopyStr(CallStack, Pos + 1));
        exit(CallStack);
    end;

    [TryFunction]
    local procedure ThrowError()
    begin
        // Throw an error to get the call stack by GetLastErrorCallstack
        Error('');
    end;
}
#endif