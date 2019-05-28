class BooksController < ActionController::API
  def index
    @author = Author.find(params[:author_id])
    @books = @author.books
    render json: @books, include: :authors, status: :ok
  end

  def show
    @author = Author.find(params[:author_id])
    @book = Book.find(params[:id])
    @books = @author.books
    if @author.books.include?(@book)
      render json: @book, include: :authors, status: :ok
    else
      render json: { message: "Cannot find that book by this author." }
    end
  end

  def create
    @author = Author.find(params[:author_id])
    @book = Book.new(book_params)

    if @book.save
      @author.books.push(@book)
      render json: @book, status: :created
    else
      render json: { errors: @book.errors }, status: :unprocessable_entity
    end
  end

  def update
    @author = Author.find(params[:author_id])
    @book = Book.find(params[:id])

    if @book.update(book_params)
      render json: @book, status: :ok
    else
      render json: { errors: @book.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    head :no_content
  end

  private

  def book_params
    params.require(:book).permit(:title, :author_id)
  end

end
