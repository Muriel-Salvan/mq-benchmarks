class DequeuedMessagesController < ApplicationController
  # GET /dequeued_messages
  # GET /dequeued_messages.json
  def index
    @dequeued_messages = DequeuedMessage.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @dequeued_messages }
    end
  end

  # GET /dequeued_messages/1
  # GET /dequeued_messages/1.json
  def show
    @dequeued_message = DequeuedMessage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @dequeued_message }
    end
  end

  # GET /dequeued_messages/new
  # GET /dequeued_messages/new.json
  def new
    @dequeued_message = DequeuedMessage.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @dequeued_message }
    end
  end

  # GET /dequeued_messages/1/edit
  def edit
    @dequeued_message = DequeuedMessage.find(params[:id])
  end

  # POST /dequeued_messages
  # POST /dequeued_messages.json
  def create
    @dequeued_message = DequeuedMessage.new(params[:dequeued_message])

    respond_to do |format|
      if @dequeued_message.save
        format.html { redirect_to @dequeued_message, notice: 'Dequeued message was successfully created.' }
        format.json { render json: @dequeued_message, status: :created, location: @dequeued_message }
      else
        format.html { render action: "new" }
        format.json { render json: @dequeued_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /dequeued_messages/1
  # PUT /dequeued_messages/1.json
  def update
    @dequeued_message = DequeuedMessage.find(params[:id])

    respond_to do |format|
      if @dequeued_message.update_attributes(params[:dequeued_message])
        format.html { redirect_to @dequeued_message, notice: 'Dequeued message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @dequeued_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dequeued_messages/1
  # DELETE /dequeued_messages/1.json
  def destroy
    @dequeued_message = DequeuedMessage.find(params[:id])
    @dequeued_message.destroy

    respond_to do |format|
      format.html { redirect_to dequeued_messages_url }
      format.json { head :no_content }
    end
  end

  def empty
    DequeuedMessage.delete_all

    respond_to do |format|
      format.html { redirect_to dequeued_messages_url }
      format.json { head :no_content }
    end
  end

end
