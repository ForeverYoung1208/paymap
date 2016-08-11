class TransfertsController < ApplicationController
  before_action :set_transfert, only: [:show, :edit, :update, :destroy]

  # GET /transferts
  # GET /transferts.json
  def index
    @transferts = Transfert.all[145..146]
  end

  def map
    
  end

  # GET /transferts/1
  # GET /transferts/1.json
  def show
  end

  # GET /transferts/new
  def new
    @transfert = Transfert.new
  end

  # GET /transferts/1/edit
  def edit
  end

  # POST /transferts
  # POST /transferts.json
  def create
    @transfert = Transfert.new(transfert_params)

    respond_to do |format|
      if @transfert.save
        format.html { redirect_to @transfert, notice: 'Transfert was successfully created.' }
        format.json { render :show, status: :created, location: @transfert }
      else
        format.html { render :new }
        format.json { render json: @transfert.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transferts/1
  # PATCH/PUT /transferts/1.json
  def update
    respond_to do |format|
      if @transfert.update(transfert_params)
        format.html { redirect_to @transfert, notice: 'Transfert was successfully updated.' }
        format.json { render :show, status: :ok, location: @transfert }
      else
        format.html { render :edit }
        format.json { render json: @transfert.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transferts/1
  # DELETE /transferts/1.json
  def destroy
    @transfert.destroy
    respond_to do |format|
      format.html { redirect_to transferts_url, notice: 'Transfert was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transfert
      @transfert = Transfert.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transfert_params
      params.require(:transfert).permit(:filename, :baz_dot, :rev_dot)
    end
end
