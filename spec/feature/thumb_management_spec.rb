require 'spec_helper'

feature 'user views thumb details' do
  row = Row.create
  thumb = Thumb.create(label: 'Thumb 1', image_path: 'http://foo.com/bar.png', active: true, row_id: row.id)

  scenario do
    visit row_path(row)
    expect(page).to have_link(thumb.label)
    expect(page).to have_link('delete')
    first('.thumb').click_link("View #{thumb.label}")
    expect(page).to have_content("Viewing thumb ##{thumb.id} for row ##{row.id}")
    expect(page).to have_content(thumb.label)
    expect(page).to have_content(thumb.image_path)
    expect(page).to have_link('Delete Thumb')
  end
end

feature 'user creates a new thumb' do
  row = Row.create

  scenario 'with invalid info' do
    visit new_row_thumb_path(row)
    expect(page).to have_content("New thumb for row ##{row.id}")
    expect { click_button 'Create Thumb' }.to_not change(row.thumbs, :count)
    expect(page).to have_content("Edit thumb for row ##{row.id}")
  end

  scenario 'with valid info' do
    visit new_row_thumb_path(row)
    expect(page).to have_content("New thumb for row ##{row.id}")
    fill_in 'Label', with: 'Thumb 1'
    fill_in 'Image path', with: 'http://www.example.com/foo.png'
    check 'Active'
    expect { click_button 'Create Thumb' }.to change { row.thumbs.count}.by(1)
    expect(page).to have_content("Row ##{row.id} thumbs")
    expect(page).to have_selector('div.thumb')
  end

end

feature 'user edits a thumb' do
  row = Row.create
  thumb = Thumb.create(label: 'Thumb 1', row_id: row.id)

  scenario 'with invalid info' do
    visit edit_row_thumb_path(row, thumb)
    expect(page).to have_content("Edit thumb for row ##{row.id}")
    fill_in 'Label', with: ''
    expect { click_button 'Update Thumb' }.to_not change(row.thumbs, :count)
    expect(page).to have_content("Edit thumb for row ##{row.id}")
  end

  scenario 'with valid info' do
    visit edit_row_thumb_path(row, thumb)
    expect(page).to have_content("Edit thumb for row ##{row.id}")
    fill_in 'Label', with: 'Poppycock'
    expect { click_button 'Update Thumb' }.to_not change(row.thumbs, :count)
    expect(page).to have_content("Viewing thumb ##{thumb.id} for row ##{row.id}")
  end
end

feature 'user deletes a thumb' do
  row = Row.create
  Thumb.create(label: 'Thumb 1', row_id: row.id)

  scenario 'by clicking delete' do
    visit row_path(row)
    expect { first('.thumb').click_link('delete') }.to change { row.thumbs.count }.by(-1)
  end
end
