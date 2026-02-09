# 用 Docker 跑 Jekyll，不依赖本机 Ruby
FROM jekyll/jekyll:4

WORKDIR /srv/jekyll

# 使用 Ruby 3.2 的镜像（jekyll/jekyll:4 基于 Ruby 3.2）
COPY Gemfile ./
RUN bundle install --jobs 4

COPY . ./

EXPOSE 4000
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--livereload"]
