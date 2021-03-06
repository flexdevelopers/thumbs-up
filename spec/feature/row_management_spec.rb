require 'spec_helper'

feature 'user views a row' do
  thumb = FactoryGirl.create(:thumb)

  scenario 'by visiting the row path' do
    visit admin_row_path(thumb.row)
    expect(page).to have_content("View Row##{thumb.row.id}")
    expect(page).to have_content(thumb.row.title)
    expect(page).to have_selector('div.thumb')
  end
end

feature 'user creates a new row' do
  create_row = 'Create new row'

  background do
    visit admin_rows_path
    expect(page).to have_link(create_row)
    click_link create_row
    expect(page).to have_content('New row')
  end

  scenario 'with invalid info' do
    expect { click_button 'Create Row' }.to_not change { Row.count }.by(1)
    expect(page).to have_content('New row')
  end

  scenario 'with valid info' do
    fill_in 'Title', with: 'Row title'
    fill_in 'Description', with: 'Row description'
    fill_in 'Link url', with: 'http://www.foo.com/good-stuff'
    expect { click_button 'Create Row' }.to change { Row.count }.by(1)
    expect(page).to have_content('Row title')
  end
end

feature 'user edits a row' do
  row = FactoryGirl.create(:row)

  background do
    visit admin_root_path
  end

  scenario 'with invalid info' do
    within "div#row_#{row.id}" do
      click_link '(edit)'
    end
    expect(page).to have_content("Edit Row##{row.id}")
    fill_in 'Title', with: ''
    click_button 'Update Row'
    expect(page).to have_content("Edit Row##{row.id}")
  end

  scenario 'with valid info' do
    within "div#row_#{row.id}" do
      click_link row.title
    end
    click_link 'Edit Row'
    expect(page).to have_content("Edit Row##{row.id}")
    fill_in 'Title', with: 'New row title'
    fill_in 'Description', with: 'row description'
    fill_in 'Link url', with: 'http://www.foo.com/bar'
    click_button 'Update Row'
    expect(page).to have_content("View Row##{row.id}")
  end

end

feature 'user deletes a row and the associated thumbs' do
  row = FactoryGirl.create(:row)
  Thumb.create(label: 'thumb label', row: row)
  Thumb.create(label: 'thumb label', row: row)

  scenario 'by clicking the delete link' do
    visit admin_rows_path
    expect(page).to have_content('Rows')
    within "div#row_#{row.id}" do
      expect(Thumb.where(row_id: row.id).count).should be == 2
      expect { click_link '(delete)' }.to change { Row.count }.by(-1)
      expect(Thumb.where(row_id: row.id).count).should be == 0
    end
  end
end