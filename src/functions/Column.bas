Attribute VB_Name = "F_Column"
Option Explicit
Option Private Module

Enum TargetColumnType
    Entire
    ToLeftEndColumns
    ToRightEndColumns
    ToLeftOfCurrentRegionColumns
    ToRightOfCurrentRegionColumns
End Enum

Private Function getTargetColumns(ByVal TargetType As TargetColumnType) As Range
    'Error handling
    On Error GoTo Catch

    'Return Nothing when selection is not Range
    If TypeName(Selection) <> "Range" Then
        Set getTargetColumns = Nothing
        Exit Function
    End If

    Dim rngSelection As Range
    Dim startColumn  As Long
    Dim endColumn    As Long

    Set rngSelection = Selection

    'Entire
    If TargetType = Entire Then
        With rngSelection
            If .Columns.Count > 1 Or gCount = 1 Then
                Set getTargetColumns = .EntireColumn
                Exit Function
            ElseIf gCount > 1 Then
                startColumn = .Column
                endColumn = .Column + gCount - 1
            End If
        End With

    'ToLeftEndColumns
    ElseIf TargetType = ToLeftEndColumns Then
        startColumn = ActiveSheet.UsedRange.Column
        endColumn = ActiveCell.Column

        'Out of range
        If startColumn > endColumn Then
            Set getTargetColumns = Nothing
            Exit Function
        End If

    'ToRightEndColumns
    ElseIf TargetType = ToRightEndColumns Then
        With ActiveSheet.UsedRange
            startColumn = ActiveCell.Column
            endColumn = .Columns(.Columns.Count).Column
        End With

        'Out of range
        If startColumn > endColumn Then
            Set getTargetColumns = Nothing
            Exit Function
        End If

    'ToLeftOfCurrentRegionColumns
    ElseIf TargetType = ToLeftOfCurrentRegionColumns Then
        startColumn = ActiveCell.CurrentRegion.Column
        endColumn = ActiveCell.Column

        'Out of range
        If startColumn > endColumn Then
            Set getTargetColumns = Nothing
            Exit Function
        End If

    'ToRightOfCurrentRegionColumns
    ElseIf TargetType = ToRightOfCurrentRegionColumns Then
        With ActiveCell.CurrentRegion
            startColumn = ActiveCell.Column
            endColumn = .Colmuns(.Columns.Count).Column
        End With

        'Out of range
        If startColumn > endColumn Then
            Set getTargetColumns = Nothing
            Exit Function
        End If

    End If

    With ActiveSheet
        If endColumn > .Columns.Count Then
            endColumn = .Columns.Count
        End If

        Set getTargetColumns = .Range(.Columns(startColumn), .Columns(endColumn))
    End With
    Exit Function

Catch:
    If Err.Number <> 0 Then
        Call errorHandler("getTargetColumns")
        Set getTargetColumns = Nothing
    End If
End Function

Private Function selectColumnsInternal(ByVal TargetType As TargetColumnType) As Boolean
    On Error GoTo Catch

    Dim savedCell As Range
    Dim Target As Range

    Set Target = getTargetColumns(TargetType)
    If Target Is Nothing Then
        Exit Function
    End If

    Call stopVisualMode

    Set savedCell = ActiveCell

    Target.Select
    savedCell.Activate

    selectColumnsInternal = True
    Exit Function

Catch:
    If Err.Number <> 0 Then
        Call errorHandler("selectColumnsInternal")
    End If
End Function

Function selectColumns(Optional ByVal TargetType As TargetColumnType = Entire)
    On Error GoTo Catch

    Call selectColumnsInternal(TargetType)
    Exit Function

Catch:
    If Err.Number <> 0 Then
        Call errorHandler("selectColumns")
    End If
End Function

Function insertColumns()
    On Error GoTo Catch

    Dim savedCell As Range
    Dim Target As Range

    Set Target = getTargetColumns(Entire)
    If Target Is Nothing Then
        Exit Function
    End If

    Call repeatRegister("insertColumns")
    Call stopVisualMode

    Application.ScreenUpdating = False

    Set savedCell = ActiveCell
    Target.Select
    savedCell.Activate

    Call keystroke(True, Alt_ + I_, C_)

Catch:
    Application.ScreenUpdating = True
    If Err.Number <> 0 Then
        Call errorHandler("insertColumns")
    End If
End Function

Function appendColumns()
    On Error GoTo Catch

    Dim savedCell As Range
    Dim Target As Range

    Set Target = getTargetColumns(Entire)
    If Target Is Nothing Then
        Exit Function
    End If

    Call repeatRegister("appendColumns")
    Call stopVisualMode

    Set savedCell = ActiveCell

    If Target.Item(Target.Count).Column < ActiveSheet.Columns.Count Then
        Set Target = Target.Offset(0, 1)
        Set savedCell = savedCell.Offset(0, 1)
    End If

    Application.ScreenUpdating = False

    Target.Select
    savedCell.Activate

    Call keystroke(True, Alt_ + I_, C_)

Catch:
    Application.ScreenUpdating = True
    If Err.Number <> 0 Then
        Call errorHandler("appendColumns")
    End If
End Function

Function deleteColumns(Optional ByVal TargetType As TargetColumnType = Entire)
    On Error GoTo Catch

    Application.ScreenUpdating = False
    If selectColumnsInternal(TargetType) = False Then
        Application.ScreenUpdating = True
        Exit Function
    End If

    Call repeatRegister("deleteColumns")
    Call stopVisualMode

    Call keystroke(True, Ctrl_ + Minus_)

Catch:
    Application.ScreenUpdating = True
    If Err.Number <> 0 Then
        Call errorHandler("deleteColumns")
    End If
End Function

Function yankColumns(Optional ByVal TargetType As TargetColumnType = Entire)
    On Error GoTo Catch

    Dim Target As Range

    Set Target = getTargetColumns(TargetType)
    If Target Is Nothing Then
        Exit Function
    End If

    Call stopVisualMode

    Target.Copy
    Set gLastYanked = Target

    Exit Function

Catch:
    If Err.Number <> 0 Then
        Call errorHandler("yankColumns")
    End If
End Function

Function cutColumns(Optional ByVal TargetType As TargetColumnType = Entire)
    On Error GoTo Catch

    Dim Target As Range

    Set Target = getTargetColumns(TargetType)
    If Target Is Nothing Then
        Exit Function
    End If

    Call stopVisualMode

    Target.Cut
    Set gLastYanked = Target

    Exit Function

Catch:
    If Err.Number <> 0 Then
        Call errorHandler("cutColumns")
    End If
End Function

Function hideColumns()
    On Error GoTo Catch

    If selectColumnsInternal(Entire) = False Then
        Exit Function
    End If

    Call repeatRegister("hideColumns")
    Call stopVisualMode

    Call keystroke(True, Ctrl_ + k0_)

Catch:
    If Err.Number <> 0 Then
        Call errorHandler("hideColumns")
    End If
End Function

Function unhideColumns()
    On Error GoTo Catch

    If selectColumnsInternal(Entire) = False Then
        Exit Function
    End If

    Call repeatRegister("unhideColumns")
    Call stopVisualMode

    'ref: https://excel.nj-clucker.com/ctrl-shift-0-not-working/
    Call keystroke(True, Ctrl_ + Shift_ + k0_)
    Exit Function

Catch:
    If Err.Number <> 0 Then
        Call errorHandler("unhideColumns")
    End If
End Function

Function groupColumns()
    On Error GoTo Catch

    Application.ScreenUpdating = False
    If selectColumnsInternal(Entire) = False Then
        Application.ScreenUpdating = True
        Exit Function
    End If

    Call repeatRegister("groupColumns")
    Call stopVisualMode

    Call keystroke(True, Alt_ + Shift_ + Right_)

Catch:
    Application.ScreenUpdating = True
    If Err.Number <> 0 Then
        Call errorHandler("groupColumns")
    End If
End Function

Function ungroupColumns()
    On Error GoTo Catch

    Application.ScreenUpdating = False
    If selectColumnsInternal(Entire) = False Then
        Application.ScreenUpdating = True
        Exit Function
    End If

    Call repeatRegister("ungroupColumns")
    Call stopVisualMode

    Call keystroke(True, Alt_ + Shift_ + Left_)

Catch:
    Application.ScreenUpdating = True
    If Err.Number <> 0 Then
        Call errorHandler("ungroupColumns")
    End If
End Function

Function foldColumnsGroup()
    On Error GoTo Catch

    Call repeatRegister("foldColumnsGroup")
    Call stopVisualMode

    Dim targetColumn As Long
    Dim i As Integer

    targetColumn = ActiveCell.Column

    For i = 1 To gCount
        Call Application.ExecuteExcel4Macro("SHOW.DETAIL(2," & targetColumn & ",FALSE)")
    Next i
    Exit Function

Catch:
    If Err.Number <> 0 Then
        Call errorHandler("foldColumnsGroup")
    End If
End Function

Function spreadColumnsGroup()
    On Error GoTo Catch

    Call repeatRegister("spreadColumnsGroup")
    Call stopVisualMode

    Dim targetColumn As Long
    Dim i As Integer

    targetColumn = ActiveCell.Column

    For i = 1 To gCount
        Call Application.ExecuteExcel4Macro("SHOW.DETAIL(2," & targetColumn & ",TRUE)")
    Next i
    Exit Function

Catch:
    If Err.Number <> 0 Then
        Call errorHandler("spreadColumnsGroup")
    End If
End Function

Function adjustColumnsWidth()
    On Error GoTo Catch

    Call repeatRegister("adjustColumnsWidth")
    Call stopVisualMode

    If gCount > 1 Then
        Selection.Resize(Selection.Rows.Count, gCount).Select
    End If

    Call keystroke(True, Alt_ + H_, O_, I_)
    Exit Function

Catch:
    If Err.Number <> 0 Then
        Call errorHandler("adjustColumnsWidth")
    End If
End Function

Function setColumnsWidth()
    On Error GoTo Catch

    Call stopVisualMode

    If gCount > 1 Then
        Selection.Resize(Selection.Rows.Count, gCount).Select
    End If

    Call keystroke(True, Alt_ + H_, O_, W_)
    Exit Function

Catch:
    If Err.Number <> 0 Then
        Call errorHandler("setColumnsWidth")
    End If
End Function

Function narrowColumnsWidth()
    On Error GoTo Catch

    Call repeatRegister("narrowColumnsWidth")
    Call stopVisualMode

    Dim currentWidth As Double
    Dim targetColumns As Range

    If TypeName(Selection) = "Range" Then
        If Not IsNull(Selection.EntireColumn.ColumnWidth) Then
            currentWidth = Selection.EntireColumn.ColumnWidth
        Else
            currentWidth = ActiveCell.EntireColumn.ColumnWidth
        End If
        Set targetColumns = Selection.EntireColumn
    Else
        currentWidth = ActiveCell.EntireColumn.ColumnWidth
        Set targetColumns = ActiveCell.EntireColumn
    End If

    If currentWidth - gCount < 0 Then
        targetColumns.EntireColumn.ColumnWidth = 0
    Else
        targetColumns.EntireColumn.ColumnWidth = currentWidth - gCount
    End If

    Set targetColumns = Nothing
    Exit Function

Catch:
    If Err.Number <> 0 Then
        Call errorHandler("narrowColumnsWidth")
    End If
End Function

Function wideColumnsWidth()
    On Error GoTo Catch

    Call repeatRegister("wideColumnsWidth")
    Call stopVisualMode

    Dim currentWidth As Double
    Dim targetColumns As Range

    If TypeName(Selection) = "Range" Then
        If Not IsNull(Selection.EntireColumn.ColumnWidth) Then
            currentWidth = Selection.EntireColumn.ColumnWidth
        Else
            currentWidth = ActiveCell.EntireColumn.ColumnWidth
        End If
        Set targetColumns = Selection.EntireColumn
    Else
        currentWidth = ActiveCell.EntireColumn.ColumnWidth
        Set targetColumns = ActiveCell.EntireColumn
    End If

    If currentWidth + gCount > 255 Then
        targetColumns.EntireColumn.ColumnWidth = 255
    Else
        targetColumns.EntireColumn.ColumnWidth = currentWidth + gCount
    End If

    Set targetColumns = Nothing
    Exit Function

Catch:
    If Err.Number <> 0 Then
        Call errorHandler("wideColumnsWidth")
    End If
End Function
