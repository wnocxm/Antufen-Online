NEW_FORM_ITEM_INFO= { }
NEW_FORM_ITEM_INFO.Main = function( m )
  while true do
      m.DoEvt = nil
      m.arg = nil
      m.result = nil
      m:WaitEvt()
      if m.DoEvt~=nil then
          m:DoEvt()
      end
    end
end
NEW_FORM_ITEM_INFO.C50426_OnClick = function( m )
m:SetResult(0)
m:InputFinished()
m:Close()
end
NEW_FORM_ITEM_INFO.C50424_OnClick = function( m )
m:SetResult(2)
m:InputFinished()
end
NEW_FORM_ITEM_INFO.C50423_OnClick = function( m )
m:SetResult(1)
m:InputFinished()
end
