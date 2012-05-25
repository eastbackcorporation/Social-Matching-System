# -*- coding: utf-8 -*-

#massage category作成
#Category.drop_all
categories=%W(介護 子守 散歩)
categories.each do |c|
  Category.create(:name=>c)
end