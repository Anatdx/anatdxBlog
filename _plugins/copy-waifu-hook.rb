# 本地 jekyll serve 时把 waifu 拷到 _site，与 tools/build-cf.sh 行为一致
require "fileutils"

Jekyll::Hooks.register :site, :post_write do |site|
  src = File.join(site.source, "waifu")
  dest = File.join(site.dest, "waifu")
  override = File.join(site.source, "waifu-override")
  next unless Dir.exist?(src)

  FileUtils.rm_rf(dest) if Dir.exist?(dest)
  FileUtils.cp_r(src, dest)
  next unless Dir.exist?(override)
  Dir.each_child(override) do |entry|
    FileUtils.cp_r(File.join(override, entry), File.join(dest, entry))
  end
end
